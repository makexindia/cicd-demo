#!/bin/bash
echo "Creating volume directories..."
mkdir -p ./jenkins_data ./workspace

echo "Adjusting basic permissions..."
# Jenkins usually runs as user jenkins (1000) or root. Since we run it as root, 777 is a safe catch-all for local demos
chmod -R 777 ./jenkins_data ./workspace

echo "Setup complete."
