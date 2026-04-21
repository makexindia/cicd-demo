#!/bin/bash

echo "Creating volume directories..."
mkdir -p ./jenkins_data ./workspace

echo "Adjusting basic permissions..."
# Jenkins usually runs as user jenkins (1000) or root. Since we run it as root, 777 is a safe catch-all for local demos
chmod -R 777 ./jenkins_data ./workspace

# Start the docker-compose stack
echo "Starting Docker Compose services..."
docker compose up -d --build

echo "Waiting for Gitea to start (this can take a minute)..."
until [ "$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)" == "200" ]; do
    sleep 5
done

echo "Setting up Gitea Admin User..."
# Idempotent: Ignore error if user already exists
docker exec -u git gitea gitea admin user create --username admin --password admin123 --email admin@example.com --admin --must-change-password=false || true

echo "Creating Gitea Repository via API..."
# Idempotent: Call API, ignore error if repo already exists
curl -s -X POST -H "Content-Type: application/json" \
  -u admin:admin123 \
  -d '{"name":"app_repo", "private":false, "default_branch": "main"}' \
  http://localhost:3000/api/v1/user/repos || true

if [ ! -d "./workspace/app_repo" ]; then
    echo "Initializing and Pushing Template Repository to Gitea..."
    cd ./app_repo
    git init
    git checkout -b main
    git config user.name "Admin"
    git config user.email "admin@example.com"
    git add .
    git commit -m "Initial commit" || true
    git push http://admin:admin123@localhost:3000/admin/app_repo.git main || true
    # Remove the .git folder so app_repo remains a clean template directory in your main workspace!
    rm -rf .git
    cd ..

    echo "Checking out code into code-server workspace..."
    git clone http://admin:admin123@localhost:3000/admin/app_repo.git ./workspace/app_repo
    cd ./workspace/app_repo
    # Update remote so pushes work from INSIDE the code-server container
    git remote set-url origin http://admin:admin123@gitea:3000/admin/app_repo.git
    cd ../..
else
    echo "Checking out code into code-server workspace..."
    # Pull from inside the container where the 'gitea' hostname resolves
    docker exec -w /config/workspace/app_repo code-server git pull origin main
fi

echo "Waiting for Jenkins to fully start..."
until [ "$(curl -s -o /dev/null -w "%{http_code}" -u "admin:admin123" http://localhost:8080/)" == "200" ]; do
    sleep 5
done

echo "Triggering Jenkins Pipeline Build..."
# Fetch a session cookie and the CSRF crumb, then trigger the build
curl -c cookies.txt -s -u "admin:admin123" http://localhost:8080/ > /dev/null
CRUMB=$(curl -s -b cookies.txt -u "admin:admin123" 'http://localhost:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')
curl -s -b cookies.txt -X POST -u "admin:admin123" -H "$CRUMB" "http://localhost:8080/job/app_pipeline/build"
rm cookies.txt # Clean up the temporary cookie file

echo ""
echo "================================================="
echo "                 Cheat Sheet"
echo "================================================="
echo "Gitea:       http://localhost:3000 (admin / admin123)"
echo "Code-Server: http://localhost:8443 (AUTH=none)"
echo "Jenkins:     http://localhost:8080 (admin / admin123)"
echo "Nginx:       http://localhost:80"
echo "================================================="
echo "Pipeline has been successfully triggered!"
echo ""
