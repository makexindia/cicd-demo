# AGENT.md: The Constitution

This file is the strict, immutable rulebook for any AI agent or copilot interacting with this codebase.

## A. Coding Directives
- All `.sh` scripts MUST use Unix LF line endings.
- NEVER use `:latest` tags. Enforce semantic versioning and verify tags exist before applying them.
- NEVER mutate container state using `docker exec` in startup scripts; use configuration mounts instead.

## B. Architectural Guardrails (Do Not Alter)
- **Gitea Storage:** MUST use a Docker Named Volume (`gitea_data:/data`) to prevent SQLite NTFS locking errors.
- **Jenkins Builder:** MUST mount the host's `/var/run/docker.sock` as root to build sibling containers.
- **Jenkins API:** Automated triggers MUST fetch and pass a CSRF crumb and session cookie.
- **Code-Server IDE:** Git configuration (`safe.directory`) MUST be handled immutably via the `/custom-cont-init.d/` mount.

## C. The Meta-Rule (The Memory Loop)
Whenever an AI agent completes a task, refactors code, or solves a bug in this repository, it MUST automatically append a summary of those changes to `walkthrough.md`. This file serves as the agent's continuous memory and changelog.
