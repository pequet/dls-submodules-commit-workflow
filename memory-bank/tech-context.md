---
type: overview
domain: system-state
subject: DLS Commit Workflow
status: active
summary: Technologies, setup, and technical constraints of the project.
---
# Technical Context

## 1. Technologies Used
List significant technologies, frameworks, libraries, tools.

* [Enter technologies here]

*   **Example: Project A**
    *   **IDE:**
        *   Cursor IDE
    *   **AI Tools:**
        *   vibe-tools
        *   SpecStory
    *   **Languages:**
        *   Markdown
        *   Bash
        *   JSON
    *   **Version Control:**
        *   Git
*   **Example: Project B**
    *   **Language:** Pine Script v5
    *   **Platform:** TradingView
    *   **Version Control:** Git
    *   **Documentation:** Markdown

## 2. Development Setup & Environment
How to set up the dev environment.

* [Enter development setup and environment here]

*   **Example: Project A**
    *   **Prerequisites:**
        *   Cursor IDE installed and configured.
        *   vibe-tools installed globally (`npm install -g vibe-tools`).
        *   API keys configured for AI providers (e.g., OpenAI, Gemini).
        *   Git installed and configured.
    *   **Setup Steps:**
        1.  Clone the repository from GitHub.
        2.  Install the required dependencies (if any).
        3.  Configure API keys in `~/.vibe-tools/.env`.
        4.  Start the Cursor IDE and open the project directory.
        5.  Review the `README.md` file for further instructions.
    *   **Example: Project B**
        *   **Prerequisites:** A TradingView account (Pro account recommended for development), Git installed, a modern text editor (like VS Code with Pine Script extensions).
        *   **Setup Steps:** 1. Clone the repository. 2. Open the project in a text editor. 3. Copy-paste script code into the TradingView Pine Editor to apply to charts for testing.

## 3. Technical Constraints
List known technical limitations.

* [Enter technical constraints here]

*   **Example: Project A**
        *   Reliance on specific AI tools and extensions.
        *   Potential for redundancy in auto-generated rules.
        *   The boilerplate may become outdated quickly due to the rapid evolution of AI technologies.
        *   The memory bank has a current limit of 2M tokens of context.
    *   **Example: Project B**
        *   Pine Script execution limits (e.g., memory, number of plots).
        *   No ability to import external data sources or libraries beyond the script itself.
        *   All code for a single indicator must be in one file.

## 4. Dependencies & Integrations (Technical Details)
Key technical details for dependencies/integrations.

* [Enter dependencies and integrations here]

*   **Example: Project A**
    *   **Dependency 1:** vibe-tools
        *   vibe-tools provides a set of CLI tools for interacting with AI providers.
    *   **Dependency 2:** SpecStory
        *   SpecStory is a Cursor extension that automatically saves AI interactions.
*   **Example: Project B**
    *   **Dependency 1:** TradingView Platform. The scripts are entirely dependent on the TradingView charting environment and its Pine Script API.

## 5. Code & Branching Strategy
Describe the version control system, branching model, and code review process.

* [Enter version control system, branching model, and code review process here]

*   **Example: Project A**
    *   **VCS:** Git
    *   **Hosting:** GitHub
    *   **Branching Model:** GitHub Flow
    *   **Code Review:** Pull requests
    *   **Commit Messages:** Conventional Commits
*   **Example: Project B**
    *   **VCS:** Git
    *   **Hosting:** GitHub
    *   **Branching Model:** Feature Branch Workflow (e.g., `feature/indicator-name`).
    *   **Code Review:** Pull requests for all changes to the `main` branch.
    *   **Commit Messages:** Conventional Commits standard.

## 6. Build & Deployment Process
Describe the build process, deployment pipeline, and hosting environment.

* [Enter build and deployment process here]

*   **Example: Project A** N/A - This boilerplate does not include a build or deployment process.
*   **Example: Project B** N/A - Deployment is manual. The developer copies the final script code and publishes it as a "Protected" or "Invite-Only" script on the TradingView platform.

---
**How to Use This File Effectively:**
This document details the technical landscape of your project. Use it to understand the tools, setup procedures, constraints, and deployment workflows. Keep it updated as new technologies are adopted, setup steps change, or the deployment process evolves. It's essential for developer onboarding and maintaining a shared understanding of the tech stack.
