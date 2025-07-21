---
type: overview
domain: system-state
subject: DLS Commit Workflow
status: active
summary: "Core project goals, requirements, and scope for the DLS Submodules Commit Workflow script."
---
# Project Brief

## 1. Project Goal

*   **Primary Objective:** To create a robust script that completely automates the commit and push workflow for a parent repository and all of its Git submodules, eliminating a tedious and error-prone manual process.

*   **Secondary Objectives (Optional):**
    *   To provide clear documentation on how to use the script.
    *   To ensure the script is reliable and handles edge cases, such as submodules with no changes.
    *   To make the script intelligent enough to always operate on the correct top-level repository.

## 2. Core Requirements & Functionality

*   **Requirement 1:** Intelligently locate the top-level repository root, traversing up from the current directory.
*   **Requirement 2:** Iterate through every submodule within the parent repository, including nested submodules in the correct bottom-up order.
*   **Requirement 3:** For each submodule, check for pending changes and, if found, add and commit them with a consistent message.
*   **Requirement 4:** After processing all submodules, add and commit any changes in the main repository, including the updated submodule pointers.
*   **Requirement 5:** Provide an option for automatically generating conventional commit messages using an AI tool (`-a` or `--ai-commit`).
*   **Requirement 6:** Provide an optional `-p` flag with two modes:
    *   `-p`: Pushes committed changes in the parent repository only.
    *   `-p all`: Pushes committed changes in all submodules first, then pushes the parent repository.
*   **Requirement 7:** Include a simple installer script (`install.sh`) to make the main script globally executable via a symlink.

*   **Future Consideration:**
    *   The installer could be enhanced to provide an option to set up a `launchd` agent for periodic, automated execution. This requires further evaluation to avoid potential conflicts in multi-user or multi-location workflows.

## 3. Target Audience

Developers and teams who use Git submodules to manage complex projects and need to simplify their version control workflow.

## 4. Scope (Inclusions & Exclusions)

### In Scope:

*   A single, executable Bash script (`dls-commit-all.sh`).
*   A simple, interactive installer script (`install.sh`) to handle global installation (symlinking).
*   Functionality to commit changes in submodules and the parent repository.
*   Support for default, user-provided (`-m`), and AI-generated (`-a`) commit messages.
*   Optional push functionality for the parent repository (`-p`) and all repositories (`-p all`).
*   Robust error handling to prevent commits if a proper Git repository is not found.
*   Concurrency locking to prevent multiple script instances from running at once.
*   Comprehensive `README.md` documentation.

### Out of Scope:

*   Automated, periodic execution via `launchd` or `cron` is out of scope for the initial version pending further review of potential workflow conflicts.
*   Any interactive user interface; this is a command-line tool.
*   Support for version control systems other than Git.
*   Complex git operations like rebase, merge, or cherry-pick. The script focuses solely on adding and committing existing changes.
*   Language versions other than Bash.

## 5. Success Criteria & Key Performance Indicators (KPIs)

*   **Success Criteria:**
    *   The script reliably commits all changes across submodules and the parent repo in a single command.
    *   The script is easy to use and understand.
    *   The script prevents common errors, like committing in the wrong directory.
*   **KPIs:**
    *   Time saved per developer during the commit process.
    *   Reduction in commit-related errors (e.g., forgetting to commit a submodule).
    *   Positive feedback from users on its utility and reliability.

## 6. Assumptions

*   Users have a basic understanding of Git and Git submodules.
*   Users are working in a Bash-compatible shell environment.
*   The script will be executed from a directory within a Git repository.

## 7. Constraints & Risks

*   **Constraints:**
    *   The script is dependent on the `git` command-line tool being installed and available in the system's PATH.
    *   The script requires `flock` for concurrency control.
    *   The AI feature requires `vibe-tools` to be installed and configured with a valid API key.
    *   It is designed only for Bash environments.
*   **Risks:**
    *   If the logic for finding the top-level repository is not robust, the script could perform Git operations in the wrong directory. (Mitigation: Use reliable git commands like `git rev-parse --show-superproject-working-tree` and `git rev-parse --show-toplevel`, and exit with an error if a valid root cannot be determined).
    *   AI API calls could fail or be rate-limited, affecting the commit message generation. (Mitigation: The script includes a fallback to a default message and a sleep interval to reduce the chance of rate-limiting).
    *   A very large number of submodules could potentially slow down the script's execution. (Mitigation: The `git submodule foreach` command is generally efficient, but performance should be kept in mind).

## 8. Stakeholders

*   **Project Sponsor:** Benjamin Pequet
*   **Product Owner:** Benjamin Pequet
*   **Development Team Lead:** N/A
*   **Marketing Lead:** N/A

## Template Usage Notes

This `project-brief.md` file, along with others in the `memory-bank/` directory, serves as a foundational part of the Memory Bank methodology. This system helps AI assistants maintain context and understanding across development sessions when working on a project initiated from this template.

