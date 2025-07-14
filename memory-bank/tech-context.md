---
type: overview
domain: system-state
subject: DLS Commit Workflow
status: active
summary: "Details the technologies, setup, and technical constraints for the commit workflow script project."
---
# Technical Context

## 1. Technologies Used
*   **Language:** Bash
*   **Core Tool:** Git
*   **AI Integration:** `vibe-tools`
*   **Development Environment:** Any Unix-like shell (e.g., Bash on macOS, Linux, or WSL on Windows).
*   **Version Control:** Git, GitHub
*   **Documentation:** Markdown

## 2. Development Setup & Environment
*   **Prerequisites:**
    *   Git must be installed and accessible from the command line.
    *   A Bash-compatible shell.
    *   `flock` for concurrency control (standard on most Linux, install via `brew install flock` on macOS).
    *   `vibe-tools` for AI features, which must be installed and configured with an API key in `scripts/vibe.config`.
*   **Setup Steps:**
    1.  Clone this repository.
    2.  Ensure all prerequisites above are met.
    3.  Run the interactive installer: `chmod +x install.sh && ./install.sh`.
    4.  The installer handles making the script globally available.

## 3. Technical Constraints
*   The script is designed for Bash and may not be compatible with other shells (like Fish or Zsh) without modification if it uses Bash-specific features.
*   The script's performance may be a consideration in repositories with an extremely large number of submodules (e.g., hundreds).
*   It relies entirely on the `git` command-line interface and its `submodule` and `rev-parse` commands. Changes in future Git versions to these commands could potentially affect the script.
*   The AI feature introduces a dependency on the `vibe-tools` CLI and a configured `scripts/vibe.config` file. An internet connection is required for AI message generation.

## 4. Dependencies & Integrations (Technical Details)
*   **Dependency 1:** `git` (command-line tool)
    *   The script is fundamentally a wrapper around a series of `git` commands. It is essential that `git` is installed and in the system's PATH.
*   **Dependency 2:** `flock` (command-line tool)
    *   Used to create a lock file and prevent multiple instances of the script from running concurrently.
*   **Dependency 3:** `vibe-tools` (command-line tool)
    *   Used to call an AI model to generate commit messages when the `-a` or `--ai-commit` flag is active. Requires its own setup and configuration.

## 5. Code & Branching Strategy
*   **VCS:** Git
*   **Hosting:** GitHub
*   **Branching Model:** Standard GitHub Flow. New features or fixes should be developed in feature branches and merged into `main` via pull requests.
*   **Commit Messages:** Adherence to the Conventional Commits specification is preferred for clear and automated versioning.

## 6. Build & Deployment Process
*   **Build Process:** N/A. As a shell script, there is no build or compilation process.
*   **Deployment Process:** Deployment is handled by the `install.sh` script. It ensures the main script is globally accessible via a symlink in `/usr/local/bin`. This is the recommended method for making the script available to the user. Automated execution is not included in the current scope.

---
**How to Use This File Effectively:**
This document details the technical landscape of your project. Use it to understand the tools, setup procedures, constraints, and deployment workflows. Keep it updated as new technologies are adopted, setup steps change, or the deployment process evolves. It's essential for developer onboarding and maintaining a shared understanding of the tech stack.
