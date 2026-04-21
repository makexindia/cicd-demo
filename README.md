# Local CI/CD Educational Lab

A completely self-contained, turnkey local CI/CD environment built with Docker Compose. Perfect for learning DevOps principles, pipeline automation, and infrastructure as code on your local machine.

## Architecture Overview

1. **Gitea**: A lightweight Git server for local source control.
2. **Code-Server**: A browser-based VS Code IDE mapped directly to your workspace, pre-configured for Git.
3. **Jenkins**: The CI/CD automation server that polls Gitea and builds your pipelines.
4. **Nginx**: The production target server where your demo application is deployed.

The `start.sh` script automates the entire provisioning process: it spins up the containers, configures Gitea via API, pushes a template repository, pre-checks out the code in the IDE, and triggers the first Jenkins pipeline.

## Quick Start

1. **Clone this repository** (or download the files).
2. **Run the start script** (requires Git Bash if on Windows):
   ```bash
   ./start.sh
   ```
3. **Wait a minute** for the automation to finish. The Cheat Sheet will be printed in your terminal!

## Teardown

To cleanly destroy the lab and wipe all local state, simply run:
```bash
./destroy.sh
```

## Cheat Sheet

| Service | Local URL | Default Credentials |
|---|---|---|
| **Gitea** | http://localhost:3000 | `admin` / `admin123` |
| **Code-Server (IDE)** | http://localhost:8443 | *No Authentication* |
| **Jenkins** | http://localhost:8080 | `admin` / `admin123` |
| **Nginx (App)** | http://localhost:80 | *N/A* |

## Reproducibility Matrix

To ensure absolute reproducibility and protect against upstream breakages, this lab pins its Docker images to specific semantic versions. Below are the exact SHA256 image digests these tags currently map to:

| Service Image | Semantic Tag | SHA256 Digest |
|---|---|---|
| `gitea/gitea` | `1.26.0` | `sha256:af07b88edbb2173d20932f9c75ebcf4e61d7d5c2d6a7ab5cc6b97cba28aea352` |
| `linuxserver/code-server` | `4.116.0-ls333` | `sha256:4620adace18935dd6ca79d77e3bc1c379e21875392192f970cf5d6b0fb4aefcd` |
| `jenkins/jenkins` | `2.555.1-lts` | `sha256:7004d07dbcdc5439fdad8853acdb029c5e3ab7a3d8190184fbf89bec66786c02` |
| `nginx` | `1.29.8` | `sha256:7f0adca1fc6c29c8dc49a2e90037a10ba20dc266baaed0988e9fb4d0d8b85ba0` |
