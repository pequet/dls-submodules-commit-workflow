---
type: capture
domain: inbox
subject: DLS Submodules Commit Workflow
status: new
summary: Explanation of the inbox directory's purpose and symbolic link usage.
---

# About the Inbox

## Purpose

This directory serves as a default location for transient and temporary files. It's a designated spot for:

-   AI-generated outputs (e.g., from `vibe-tools plan`).
-   Quick notes and rough drafts.
-   Temporary downloads or assets.
-   Any other disposable content related to the project.

In the Boilerplate, the contents of this directory are not ignored by Git, but you should change this by uncommenting the relevant lines in the project's `.gitignore` file.

## Advanced Usage: Symbolic Link

For developers using this boilerplate within a larger organizational framework of which this is a submodule, this `inbox` directory can be replaced with a symbolic link to a central, system-wide inbox.

For example, if your main project structure has a primary inbox at `../../Models/0. Inbox/`, you can link it as follows:

```bash
# First, remove the default inbox directory if it exists
rm -r inbox

# Then, create a symbolic link to your framework's inbox
ln -s "../../Models/0. Inbox/" inbox
```

This allows you to maintain a clean, professional public repository while leveraging a powerful private backend for development and knowledge management. 