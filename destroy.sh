#!/bin/bash

echo "Tearing down Docker Compose services and removing volumes..."
docker compose down -v

echo "Cleaning up rogue Jenkins-deployed containers and images..."
# Stop and remove the nginx container if it exists (ignore errors if it doesn't)
docker stop nginx 2>/dev/null || true
docker rm nginx 2>/dev/null || true

# Remove the custom image built by Jenkins to ensure a fresh build next run
docker rmi demo-website:latest 2>/dev/null || true

echo "Deleting local volume folders..."
rm -rf ./jenkins_data ./workspace

echo "Cleanup complete. The lab is completely reset!"
