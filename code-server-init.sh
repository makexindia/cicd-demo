#!/bin/bash
echo "Configuring global git settings for Code-Server..."
git config --global --add safe.directory '*'
git config --global user.name "Student"
git config --global user.email "student@example.com"
