---
type: overview
domain: system-state
subject: DLS Commit Workflow
status: active
summary: "Documents the architecture, key design decisions, and system patterns for the commit workflow script."
---
# System Patterns

## 1. System Architecture Overview

*   **Overall architecture & justification?** *(e.g., Monolithic, Microservices, Client-Server)*
    *   The project architecture is a single, monolithic, and standalone Bash script. This is the simplest and most effective architecture for a command-line tool designed to perform a specific, focused task. It has no external runtime dependencies other than Git and a Bash shell, making it highly portable and easy to distribute.

*   **High-Level Diagram Link (Recommended):**
    *   N/A

## 2. Key Architectural Decisions & Rationales

*   **Decision 1:** Use a single Bash script.
    *   **Rationale:** Simplicity and portability. A shell script is the most direct way to interact with a command-line tool like Git and requires no complex setup or environment.
*   **Decision 2:** Implement intelligent top-level directory finding.
    *   **Rationale:** This is a critical safety and usability feature. It prevents the script from running in an unintended directory (like a submodule's root) and allows the user to run the command from anywhere within the project's file tree. The use of `git rev-parse --show-superproject-working-tree` and `git rev-parse --show-toplevel` will be key.
*   **Decision 3:** Use `git submodule foreach` for iteration.
    *   **Rationale:** This is the canonical and most efficient Git command for performing an operation on every registered submodule, ensuring none are missed.
*   **Decision 4:** Use `git diff-index --quiet HEAD --` to check for changes.
    *   **Rationale:** This is a safe and performant way to check for pending changes in a submodule without producing unnecessary output, allowing the script to cleanly report which submodules have nothing to commit.
*   **Decision 5:** Integrate AI for commit message generation.
    *   **Rationale:** To further reduce developer friction and save time by automating the creation of conventional commit messages. This elevates the script from a simple automation tool to an intelligent assistant. It uses `vibe-tools` for easy integration with various AI providers.
*   **Decision 6:** Make pushing an optional flag (`--push`).
    *   **Rationale:** Committing and pushing are distinct operations. The default behavior should be non-destructive to the remote. This gives the user a chance to review local commits before pushing them, adhering to a safer workflow.

## 3. Design Patterns in Use

*   **Pattern 1:** Wrapper/Facade
    *   **Example:** The script acts as a facade, providing a simple, high-level interface (`dls-commit-all.sh`) that encapsulates a more complex series of underlying `git` commands.
*   **Pattern 2:** Template Method (Conceptual)
    *   **Example:** The script follows a fixed sequence of operations: 1. Find Root, 2. Loop Submodules, 3. Commit Parent, 4. Optional Push. This defines an unchangeable algorithm skeleton.

## 4. Component Relationships & Interactions
*   As a single script, there are no internal components. The script's primary interaction is with the host system's shell and the `git` executable.

## 5. Data Management & Storage
*   **Primary Datastore & Rationale:**
    *   N/A. The script is stateless. It reads the state of the Git repository from the file system but does not store any data itself.

## 6. Integration Points with External Systems
*   **System 1:** Git
    *   The script is entirely dependent on the `git` command-line tool being present on the system. It integrates tightly with Git to read repository state and perform commit and push operations.
*   **System 2:** `vibe-tools`
    *   The script integrates with the `vibe-tools` CLI to provide AI-powered commit message generation. This introduces a dependency on this tool and its configuration for the AI features to work.

---
**How to Use This File Effectively:**
This document outlines the technical blueprint of the system. Refer to it for understanding architectural choices, design patterns, and how components interact. Update it when significant architectural decisions are made, new patterns are introduced, or data management strategies change. It is crucial for onboarding new developers and ensuring consistent technical approaches.
