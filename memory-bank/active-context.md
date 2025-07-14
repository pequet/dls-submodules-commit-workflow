---
type: overview
domain: system-state
subject: DLS Commit Workflow
status: active
summary: "The core script has been enhanced with a major new feature for AI-powered commit messages. The current focus is on updating all project documentation to reflect this new capability."
---
# Active Context

## Current Focus
The immediate priority is to systematically review and update all project documentation (`README.md`, Memory Bank files) to accurately describe the new AI-powered commit message generation feature and its implications for usage, setup, and the overall system design.

## Recent Changes
*   A major feature (`-a`, `--ai-commit`) was added to `dls-commit-all.sh` to generate conventional commit messages automatically using `vibe-tools`.
*   The script now depends on a `scripts/vibe.config` file for AI provider and model configuration.
*   The script now includes concurrency locking via `flock` to prevent multiple instances from running simultaneously.
*   The `README.md` has been updated to reflect these new features and usage patterns.

## Next Steps

*   **Update Documentation:** Systematically update all Memory Bank files to bring them into alignment with the script's final feature set.
*   **Test New Feature:** Manually test the AI commit generation in a test repository to ensure it works as expected.
*   **Implement Installer:** Resume development of the `install.sh` script to provide a simple, global installation method.
