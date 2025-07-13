#!/bin/bash

# Standard Error Handling
set -e
set -u
set -o pipefail

# █████  DLS Commit Workflow
# █  ██  Version: 1.0.0
# █ ███  Author: Benjamin Pequet
# █████  GitHub: https://github.com/pequet/dls-submodules-commit-workflow/
#
# Purpose:
#   Automates the process of committing changes in all Git submodules and
#   the parent repository. It simplifies the workflow for projects that use
#   submodules extensively, ensuring all changes are captured in a single run.
#
# Usage:
#   ./scripts/dls-commit-all.sh [-m "Your commit message"] [-p]
#
# Options:
#   -m "message"  (Optional) The commit message to use for all commits.
#                 Defaults to "chore: automatic commit".
#   -p            (Optional) Push all changes to the remote after committing.
#   -h, --help    Show this help message and exit.
#
# Dependencies:
#   - git
#
# Changelog:
#   1.0.0 - 2025-07-13 - Initial release.
#
# Support the Project:
#   - Buy Me a Coffee: https://buymeacoffee.com/pequet
#   - GitHub Sponsors: https://github.com/sponsors/pequet

# --- Global Variables ---
# Resolve the true script directory, following symlinks
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# Source shared utilities
# shellcheck source=./utils/logging_utils.sh
source "${SCRIPT_DIR}/utils/logging_utils.sh"
# shellcheck source=./utils/messaging_utils.sh
source "${SCRIPT_DIR}/utils/messaging_utils.sh"

# --- Function Definitions ---

# *
# * Usage and Information
# *
usage() {
    echo "Usage: $0 -m \"Your commit message\" [-p]"
    echo "Automates committing changes in submodules and the parent repository."
    echo
    echo "Options:"
    echo "  -m \"message\"  (Required) The commit message to use."
    echo "  -p              (Optional) Push changes to the remote after committing."
    echo "  -h, --help      Show this help message."
}

# *
# * Git Operations
# *
find_repo_root() {
    print_info "Finding repository root..."
    git rev-parse --show-toplevel
}

commit_submodules() {
    local commit_message=$1
    print_info "Checking submodules for changes..."
    
    export commit_message
    export -f print_info print_success print_warning

    git submodule foreach '
        if [ -n "$(git status --porcelain)" ]; then
            print_info "Committing changes in submodule $name..."
            git add .
            git commit -m "$commit_message"
            print_success "Committed changes in submodule $name"
        else
            print_warning "No changes to commit in submodule $name."
        fi
    '
}

commit_parent_repo() {
    local commit_message=$1
    print_info "Checking parent repository for changes..."
    
    if [ -n "$(git status --porcelain)" ]; then
        print_info "Committing changes in the parent repository..."
        git add .
        git commit -m "$commit_message"
        print_success "Committed changes in the parent repository."
    else
        print_warning "No changes to commit in the parent repository."
    fi
}

push_changes() {
    print_info "Pushing all changes to the remote..."
    git push --recurse-submodules=on-demand
    print_success "All changes have been pushed to the remote."
}

# --- Script Entrypoint ---
main() {
    print_header "DLS Submodules Commit Workflow"

    local commit_message=""
    local push_changes_flag=false

    while getopts ":m:p" opt; do
        case ${opt} in
            m )
                commit_message=$OPTARG
                ;;
            p )
                push_changes_flag=true
                ;;
            h )
                usage
                exit 0
                ;;
            \? )
                print_error "Invalid option: -$OPTARG"
                usage
                exit 1
                ;;
            : )
                print_error "Option -$OPTARG requires an argument."
                usage
                exit 1
                ;;
        esac
    done
    shift $((OPTIND -1))

    if [ -z "$commit_message" ]; then
        commit_message="chore: automatic commit"
        print_warning "No commit message provided. Using default: '$commit_message'"
    fi

    local repo_root
    repo_root=$(find_repo_root)
    cd "$repo_root"
    print_info "Operating in repository: $repo_root"
    
    commit_submodules "$commit_message"
    commit_parent_repo "$commit_message"
    
    if [ "$push_changes_flag" = true ]; then
        push_changes
    fi

    print_footer "Script logic finished."
}

main "$@" 