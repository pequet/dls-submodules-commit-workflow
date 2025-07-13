# DLS Submodules Commit Workflow

This repository contains a script to automate the commit workflow for a parent repository and all of its Git submodules. It simplifies the process of synchronizing changes across a complex project structure.

## Reasoning

In projects with numerous submodules (public and private), the process of committing changes is cumbersome and error-prone. It requires manually navigating into each submodule, staging and committing changes, and then finally committing the parent repository to update the submodule pointers. This script was created to solve that friction.

## The Script: `dls-commit-all.sh`

The core of this repository is the `scripts/dls-commit-all.sh` script.

### How it Works

1.  **Finds Project Root**: The script intelligently traverses up from the current directory to find the top-level parent repository, ensuring it doesn't accidentally run on a submodule.
2.  **Iterates Through Submodules**: It uses `git submodule foreach` to execute commands within every submodule directory.
3.  **Checks for Changes**: For each submodule, it safely checks if there are any staged or unstaged changes.
4.  **Commits Submodule Changes**: If changes are found, it automatically stages all of them (`git add .`) and commits them using a provided or default commit message.
5.  **Commits Parent Repository**: After all submodules are processed, it creates a final commit in the parent repository, which updates the submodule pointers to their new state.
6.  **Optional Message**: It includes an optional `--message` flag to specify a custom commit message. When not provided, the script uses a default message (e.g. "CHORE: Automatic sync [dls-commit-all.sh]").
7.  **Optional Push**: It includes an optional `--push` flag to push all committed changes (in the parent repo) to the remote origin.

### Usage

Once installed, you can run the `dls-commit-all.sh` command from any directory.

```bash
# Commit all changes with a custom message
dls-commit-all.sh "My daily update"

# Commit with a custom message and push to remote
dls-commit-all.sh "My daily update" --push

# Commit with the default "chore: Automatic sync" message
dls-commit-all.sh
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

## License

This project is licensed under the MIT License.

## Support the Project

If you find this project useful and would like to show your appreciation, you can:

- [Buy Me a Coffee](https://buymeacoffee.com/pequet)
- [Sponsor on GitHub](https://github.com/sponsors/pequet)
- [Deploy on DigitalOcean](https://www.digitalocean.com/?refcode=51594d5c5604) (affiliate link $)

Your support helps in maintaining and improving this project. 

