# Antigravity Memory Journal: Local CI/CD Educational Lab

This file serves as the continuous memory and changelog for AI agents interacting with this repository.

## Current Architecture
The lab provides a turnkey, container-based CI/CD environment consisting of:
- **Gitea:** A lightweight source control server.
- **Code-Server:** A browser-based VS Code IDE mapped to the local workspace.
- **Jenkins:** An automation server configured to poll Gitea and execute pipelines via Docker-outside-of-Docker (DooD).
- **Nginx:** The target server where the built demo application is deployed.

## Bugs Resolved & Key Refactoring
1. **Gitea NTFS Locking:** Fixed `disk I/O error` by migrating the Gitea storage from a Windows bind mount to a Docker Named Volume (`gitea_data:/data`), ensuring proper SQLite locking on the native filesystem.
2. **Code-Server Git Ownership:** Addressed `fatal: detected dubious ownership` and `Author identity unknown` issues by injecting an immutable configuration script into `/custom-cont-init.d/`, ensuring the global `safe.directory` is set on startup rather than using `docker exec`.
3. **Jenkins CSRF Crumbs:** Automated pipeline triggers via `curl` were failing due to 403 Forbidden errors. We implemented a secure session-based crumb fetch utilizing a cookie jar, allowing robust API integration in `start.sh`.
4. **Idempotency & Cleanup:** Refactored `start.sh` to initialize and push the template `./app_repo` folder to Gitea, and immediately `rm -rf .git` to prevent nested submodule tracking in the host workspace.
5. **Deterministic Versioning:** Replaced all fragile `:latest` tags with explicitly verified semantic versions (`1.26.0`, `4.116.0-ls333`, `2.555.1-lts`, `1.29.8`) to bulletproof the repository against upstream breaking changes.

## Current Repository Structure
```text
/cicd-demo
├── .gitignore
├── AGENT.md                  # AI Constitution and Guardrails
├── README.md
├── walkthrough.md            # Continuous AI Memory Journal
├── docker-compose.yml
├── start.sh
├── destroy.sh
├── app_repo/                 # Template source code
├── ide_config/               # Immutable IDE configuration scripts
│   └── code-server-init.sh
└── jenkins_config/           # Custom Jenkins build context
    ├── Dockerfile
    ├── init.groovy
    └── plugins.txt
```

## Agent Memory Loop Updates
- **Quality Gate Integration:** Added a `Test` stage to `app_repo/Jenkinsfile` that implements a case-insensitive grep check for the word "bug" in `index.html`, purposefully failing the build to demonstrate CI/CD blocking capabilities.
- **Documentation Bulletproofing:** Updated `README.md` to include a Codespaces analogy emphasizing the zero-local-setup nature of the lab. Added explicit OS-specific prerequisites (Git Bash for Windows) and mapped out the required free host ports. Included instructions for users to trigger the Quality Gate demo.
