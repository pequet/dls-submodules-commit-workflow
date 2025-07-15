---
type: overview
domain: system-state
subject: DLS Commit Workflow
status: active
summary: "A new feature for a smarter sleep mechanism is being added before the initial public release."
---
# Active Context

## Current Focus
A new feature for a smarter, dynamic sleep mechanism is the next priority. Once this is implemented and tested, the project will be ready for its initial public release.

## Recent Changes
*   **New Feature Idea:** A feature for a smarter sleep mechanism to account for user interaction time has been proposed and logged.
*   **Interactive Commits:** An `-i` or `--interactive` flag was added to allow for confirmation or overriding of AI-generated commit messages.
*   A major feature (`-a`, `--ai-commit`) was added to `dls-commit-all.sh` to generate conventional commit messages automatically using `vibe-tools`.
*   The script now depends on a `scripts/vibe.config` file for AI provider and model configuration.
*   The script now includes concurrency locking via `flock` to prevent multiple instances from running simultaneously.
*   The `README.md` has been updated to reflect these new features and usage patterns.
*   The `install.sh` script is complete and tested.

## Next Steps

*   **Implement Smarter Sleep:** Add the dynamic sleep calculation to the `dls-commit-all.sh` script.
*   **Testing:** Test the new sleep mechanism thoroughly.
*   **Public Release:** Perform a final review and publish the project on GitHub.
