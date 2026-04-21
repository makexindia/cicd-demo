#!/bin/bash

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

echo "Initializing and Pushing Local Git Repository (Idempotent)..."
cd ./app_repo
if [ ! -d ".git" ]; then
    git init
    git checkout -b main
    git config user.name "Admin"
    git config user.email "admin@example.com"
fi
git add .
# Commit might fail if there's nothing to commit, so we use || true
git commit -m "Initial commit" || true
# Check if remote exists before adding
git remote get-url origin > /dev/null 2>&1 || git remote add origin http://admin:admin123@localhost:3000/admin/app_repo.git
# Check if remote url is different and update it
git remote set-url origin http://admin:admin123@localhost:3000/admin/app_repo.git
git push -u origin main
cd ..

echo "Checking out code into code-server workspace..."
if [ ! -d "./workspace/app_repo" ]; then
    git clone http://admin:admin123@localhost:3000/admin/app_repo.git ./workspace/app_repo
else
    cd ./workspace/app_repo
    git pull origin main
    cd ../..
fi

echo "Waiting for Jenkins to fully start..."
until [ "$(curl -s -o /dev/null -w "%{http_code}" -u "admin:admin123" http://localhost:8080/)" == "200" ]; do
    sleep 5
done

echo "Triggering Jenkins Pipeline Build..."
# Retrieve CSRF crumb and build the job
CRUMB=$(curl -s -u "admin:admin123" 'http://localhost:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')
curl -s -X POST -u "admin:admin123" -H "$CRUMB" "http://localhost:8080/job/app_pipeline/build"

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
