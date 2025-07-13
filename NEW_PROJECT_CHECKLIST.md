# New Project Checklist

This checklist provides the steps to initialize a new project from this boilerplate.

## 1. Project Setup & Attribution

- [ ] **Global Search & Replace:**
  - [ ] Perform a global search-and-replace for the following boilerplate-specific placeholders across the entire project:
    - [ ] `dls-submodules-commit-workflow` (kebab-case name)
    - [ ] `DLS Submodules Commit Workflow` (Title Case name)
    - [ ] `Benjamin Pequet` (Author name)
    - [ ] `pequet` (GitHub username and support link paths)
- [ ] **Rename Project Directory:**
  - [ ] Rename the root directory from `dls-submodules-commit-workflow` to your new project name.
- [ ] **Update `LICENSE`:**
  - [ ] Update the copyright year and holder name in the `LICENSE` file.
- [ ] **Configure `.gitignore`:**
  - [ ] Uncomment the following lines in your `.gitignore` file to exclude boilerplate-specific context from your new project's repository:
    ```
    # .cursor
    # .cursor/
    # inbox
    # inbox/
    # archives
    # archives/
    # memory-bank
    # memory-bank/
    ```

## 2. Configuration

- [ ] **Configure `vibe-tools`:**
  - [ ] Review `vibe-tools.config.json` and adjust the default models and settings if necessary.
  - [ ] Create a `~/.vibe-tools/.env` file and add your API keys for the AI providers you plan to use (e.g., `OPENAI_API_KEY`, `GEMINI_API_KEY`).
- [ ] **Review & Update Cursor Rules:**
  - [ ] Familiarize yourself with the rules in `.cursor/rules/`.
  - [ ] **Crucial:** Update `.cursor/rules/290-script-attribution-standards.mdc` with your own author, project, and link information. The script templates in this file will be incorrect until you do.
  - [ ] Modify or add other rules as needed for your project's specific requirements.

## 3. Initialize the Memory Bank (Critical Step)

Every project, no matter how small, benefits from a well-maintained Memory Bank. Projects evolve, requirements change, and context is easily lost. The Memory Bank is your project's long-term memory, ensuring you and the AI can always understand the history and intent behind the code.

**It is strongly recommended that you initialize and maintain the Memory Bank from day one.**

- [ ] **Review the Core Concept:**
  - [ ] Read and understand the Memory Bank system as defined in rule `.cursor/rules/210-memory-bank.mdc`.
- [ ] **Initialize the Boilerplate Memory Bank:**
  - [ ] Run the command `initialize memory bank` in the AI chat. This will trigger the AI to review the existing boilerplate memory files and guide you through populating them with your project's specific context.
- [ ] **Commit to a "Memory First" Workflow:**
  - [ ] Before starting new work, check the Memory Bank for existing context.
  - [ ] After completing work, update the Memory Bank (especially `development-log.md` and `active-context.md`) with your changes and decisions.

## 4. Documentation Review

- [ ] **Review Boilerplate Docs:**
  - [ ] Read `docs/000-Framework-Context.md` to understand the philosophy behind this boilerplate.
  - [ ] Read `docs/010-Development-Workflow.md` for the suggested development workflow.
  - [ ] Update or remove these documents as they fit into your new project.
- [ ] **Review `PREFLIGHT.md`:**
  - [ ] Update the `PREFLIGHT.md` checklist to suit your project's deployment or release process.
- [ ] **Update `README.md`:**
  - [ ] Edit the `README.md` to describe your new project, removing boilerplate-specific information.

