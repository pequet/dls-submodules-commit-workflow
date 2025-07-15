# DLS Submodules Commit Workflow

This repository contains a script to automate the commit workflow for a parent repository and all of its Git submodules. It simplifies the process of synchronizing changes across a complex project structure.

## Reasoning

In projects with numerous submodules (public and private), the process of committing changes is cumbersome and error-prone. It requires manually navigating into each submodule, staging and committing changes, and then finally committing the parent repository to update the submodule pointers. This script was created to solve that friction.

## The Script

The core of this repository is the `scripts/dls-commit-all.sh` script.

### How it Works

1.  **Finds Project Root**: The script intelligently traverses up from the current directory to find the top-level parent repository, ensuring it doesn't accidentally run on a submodule.
2.  **Iterates Through Submodules**: It uses `git submodule foreach` to execute commands within every submodule directory.
3.  **Checks for Changes**: For each submodule, it safely checks if there are any staged or unstaged changes.
4.  **Commits Submodule Changes**: If changes are found, it automatically stages all of them (`git add .`) and commits them using a provided or default commit message.
5.  **Commits Parent Repository**: After all submodules are processed, it creates a final commit in the parent repository, which updates the submodule pointers to their new state.
6.  **AI-Generated Commit Messages**: Includes an optional `-a` or `--ai-commit` flag to automatically generate a conventional commit message for each repository with changes using `vibe-tools`. This feature requires `vibe-tools` to be installed and configured.
7.  **Custom Commit Messages**: Includes an optional `-m "message"` flag to specify a custom commit message. This is ignored if the `--ai-commit` flag is used.
8.  **Optional Push**: It includes a `-p` flag with two modes:
    *   `-p`: Pushes changes in the **parent repository only**.
    *   `-p all`: Pushes changes in all submodules first, then the parent repository.
9.  **Directory Path**: It accepts an optional `DIRECTORY` path to specify which repository to operate on.

### Usage

Once installed, you can run the `dls-commit-all.sh` command from any directory within your Git repository.

```bash
# Automatically generate commit messages with AI (no push)
dls-commit-all.sh -a

# Automatically generate commit messages with AI and push only the parent repository to remote
dls-commit-all.sh -a -p

# Commit all changes of a remote repository with a custom message (no push)
dls-commit-all.sh /path/to/my/project -m "My daily update"

# Commit and push EVERYTHING (submodules and parent)
dls-commit-all.sh -m "My daily update" -p all
```

## Installation

An installer script is provided to make the command globally available on your system.

1.  Open your Terminal.
2.  Navigate to the directory where you cloned this repository.
3.  Run the installer:

```bash
./install.sh
```

The script will ask for your administrator password to create a symbolic link in `/usr/local/bin`.

**Benefit of Installation:** Once installed, the script integrates with your command line. You can type `dls-` and press the `Tab` key to see and auto-complete `dls-commit-all.sh`, along with any other `dls-` scripts you have installed. (Note: You may need to open a new terminal or run `rehash` for the command to become available in your current session).

## License

This project is licensed under the MIT License.

## Support the Project

If you find this project useful and would like to show your appreciation, you can:

- [Buy Me a Coffee](https://buymeacoffee.com/pequet)
- [Sponsor on GitHub](https://github.com/sponsors/pequet)
- [Deploy on DigitalOcean](https://www.digitalocean.com/?refcode=51594d5c5604) (affiliate link $)

Your support helps in maintaining and improving this project. 

