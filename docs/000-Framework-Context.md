---
type: guide
domain: methods
subject: General
status: active
tags: notes-active
summary: "Explains the boilerplate's context within the parent framework."
---

> [!NOTE]
> This document originates from a boilerplate template which may have evolved since this project was created. The latest version can be found in the [dls-submodules-commit-workflow repository](https://github.com/pequet/dls-submodules-commit-workflow/blob/main/docs/000-Framework-Context.md).

# Framework Context

This public repository, while fully functional on its own, is designed to serve as a **submodule** within a larger, homegrown and highly opinionated private framework for integrated thinking. The current document is thus a "convex mirror" looking out from the repository into the framework that gives it context.

For a standalone user, this information is optional. For the developer concerned with the system-level context, it is crucial, embodying the design principle: "when in doubt, zoom out."

## A Progressively Unfolding Structure

The parent framework's architecture is best understood by progressively unfolding its layers, from the highest level down to the specific location of this repository.

### Level 1: The `Core` and `Projects`

At the highest level, the entire system is divided into two main parts:

```text
Root/
├── Core/         # The stable, shared foundation
└── Projects/     # Modular "plugins" that extend the Core
```

-   **`Core`:** Contains the stable, foundational elements of the system.
-   **`Projects`:** A collection of modular "plugins" that extend the `Core`. This public repository is part of a `Project` called `Seed`.

### Level 2: The `MVC` Pattern in Projects

Each `Project`, including `Seed`, is organized using the Model-View-Controller (MVC) architectural pattern:

```text
Projects/
└── Seed/
    ├── Controllers/  # Logic connecting Models and Views
    ├── Models/       # Data and business logic
    └── Views/        # User interfaces and public-facing elements
```

-   **`Models`:** Holds the data, logic, and state.
-   **`Views`:** Contains all user-facing interfaces. This is where public repositories like the one you're in now reside.
-   **`Controllers`:** The operational logic that connects `Models` and `Views`.

### Level 3: The `PARA` Method for Models

The `Models` directory, which acts as the data and knowledge hub for the `Seed` project, is further structured using the PARA method following an action-oriented structure:

```text
Models/
├── 0. Inbox/       # For capturing all new, unprocessed information
├── 1. Projects/    # Actionable projects with defined goals
├── 2. Knowledge/   # (Areas) Long-term topics of interest
├── 3. Resources/   # Topic-based reference materials
├── 4. Archives/    # Completed or inactive items
└── Meta/           # Project metadata and state
```

### Locating This Repository

Putting it all together, this public repository (`dls-submodules-commit-workflow/`) is a `View` within the `Seed` `Project`.

```text
Projects/
└── Seed/
    ├── Controllers/
    ├── Models/
    │   ├── 0. Inbox/
    │   ├── 1. Projects/
    │   ├── 2. Knowledge/
    │   ├── 3. Resources/
    │   ├── 4. Archives/
    │   └── Meta/
    └── Views/
        └── Public Repositories/
            ├── private/
            └── dls-submodules-commit-workflow/  # <-- This Public Repo
```

## Development Principles

This layered structure enables a powerful and organized development workflow guided by three key principles:

-   **Inbox-Driven Development:** All new ideas, notes, tasks, and raw information related to this project are first captured in the parent `Models/0. Inbox/`. This keeps the public repository clean while ensuring no idea is lost.
-   **Archival Over Deletion:** Following a "never delete" principle, files are moved to the parent `Models/4. Archives/` instead of being deleted. This preserves a complete history of the project's evolution.
-   **Private Asset Management:** The sibling `private/` directory stores development artifacts (`.cursor/`, `.specstory/`, `memory-bank/`) that are essential for development and should be versioned in the private parent repository, but are not part of the public-facing submodule. 
