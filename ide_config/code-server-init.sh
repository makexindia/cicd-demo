#!/bin/bash
echo "Configuring global git settings for Code-Server..."
git config --global --add safe.directory '*'
git config --global user.name "Student"
git config --global user.email "student@example.com"

# Prevent Ghost Modifications caused by Windows mounts
git config --global core.fileMode false
git config --global core.autocrlf true
git config --global core.ignorecase false

echo "Configuring VS Code settings for a clean UX..."
mkdir -p /config/data/User
cat << 'EOF' > /config/data/User/settings.json
{
    "security.workspace.trust.enabled": false,
    "workbench.startupEditor": "none",
    "workbench.colorTheme": "Default Dark Modern",
    "telemetry.telemetryLevel": "off",
    "update.showReleaseNotes": false
}
EOF
chown -R 1000:1000 /config/data/User
