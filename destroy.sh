#!/bin/bash

echo "Tearing down Docker Compose services and removing volumes..."
docker compose down -v

echo "Deleting local volume folders..."
rm -rf ./jenkins_data ./workspace

echo "Cleanup complete."
