#!/bin/bash

# Standard Error Handling
set -e
set -u
set -o pipefail
trap 'echo "ERROR: Script failed at line $LINENO: $BASH_COMMAND" >&2' ERR

# █████  DLS Commit Workflow
# █  ██  Version: 1.0.2
# █ ███  Author: Benjamin Pequet
# █████  GitHub: https://github.com/pequet/dls-submodules-commit-workflow/
#
# Purpose:
#   Automates the process of committing changes in all Git submodules and
#   the parent repository. It simplifies the workflow for projects that use
#   submodules extensively, ensuring all changes are captured in a single run.
#
# Usage:
#   ./scripts/dls-commit-all.sh [DIRECTORY] [-m "Your commit message"] [-p]
#
# Options:
#   DIRECTORY     (Optional) The path to the Git repository. Defaults to the
#                 current directory's repository root.
#   -m "message"  (Optional) The commit message to use for all commits.
#                 Defaults to "CHORE: Automatic commit [dls-commit-all]".
#   -a, --ai-commit (Optional) Automatically generate the commit message for
#                 each repository/submodule with changes using AI. If this
#                 flag is present, the -m flag is ignored.
#   -i, --interactive (Optional) When used with -a, prompts the user to
#                 confirm or override the AI-generated commit message.
#   -p [all]      (Optional) Push changes.
#                 -p: Push the parent repository only.
#                 -p all: Push submodules, then the parent.
#   -h, --help    Show this help message and exit.
#
# Dependencies:
#   - git
#
# Changelog:
#   1.0.2 - 2026-01-26 - CRITICAL: Add iCloud placeholder detection before all commits.
#   1.0.1 - 2026-01-25 - Add ERR trap and per-submodule error handling for better diagnostics.
#   1.0.0 - 2025-07-13 - Initial release.
#
# Support the Project:
#   - Buy Me a Coffee: https://buymeacoffee.com/pequet
#   - GitHub Sponsors: https://github.com/sponsors/pequet

# --- Script Configuration ---
COMMIT_MESSAGE_SUFFIX_TEMPLATE="[dls-commit-all]"

# --- Global Variables ---
INTERACTIVE_MODE=false
# Resolve the true script directory, following symlinks
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

CONFIG_FILE="${SCRIPT_DIR}/vibe.config"
LOCK_FILE="/tmp/dls-commit-all.lock"
LOG_FILE_PATH="${SCRIPT_DIR}/logs/commit-all.log"

# Source shared utilities
source "${SCRIPT_DIR}/utils/logging_utils.sh"
source "${SCRIPT_DIR}/utils/messaging_utils.sh"

# --- Function Definitions ---

# *
# * Configuration and Dependencies
# *
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_error "Configuration file not found: ${CONFIG_FILE}"
        print_error "Ensure 'vibe.config' exists in the script directory."
        exit 1
    fi
    
    # shellcheck source=./vibe.config
    if ! source "$CONFIG_FILE"; then
        print_error "Failed to load configuration from ${CONFIG_FILE}"
        exit 1
    fi
}

check_dependencies() {
    if ! command -v git &> /dev/null; then
        print_error "git not found, but is required. Please install it."
        exit 1
    fi
    if ! command -v flock &> /dev/null; then
        print_error "flock not found. Please install it (e.g., 'brew install flock')."
        exit 1
    fi
}

check_ai_dependencies() {
    if ! command -v vibe-tools &> /dev/null; then
        print_error "vibe-tools not found, but is required for AI commits. Please install it."
        exit 1
    fi
}

# *
# * Usage and Information
# *
usage() {
    echo "Usage: $0 [DIRECTORY] [-m \"Your commit message\" | -a] [-p [all]]"
    echo "Automates committing changes in submodules and the parent repository."
    echo
    echo "Arguments:"
    echo "  DIRECTORY         (Optional) The path to the repository. Defaults to the current repository."
    echo
    echo "Options:"
    echo "  -m \"message\"    (Optional) The commit message to use. Defaults to 'CHORE: Automatic commit [dls-commit-all]'."
    echo "  -a, --ai-commit   (Optional) Automatically generate commit messages using AI. Overrides -m."
    echo "  -i, --interactive (Optional) With -a, prompt to confirm/override AI-generated messages."
    echo "  -p [all]          (Optional) Push changes to the remote."
    echo "                    'all': Pushes submodules first, then the parent."
    echo "                    (default): Pushes parent repository only."
    echo "  -h, --help        Show this help message."
}

# *
# * Git Operations
# *
find_repo_root() {
    local search_dir="$1"
    
    if ! git -C "$search_dir" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        print_error "Directory is not in a git repository: $search_dir"
        usage
        exit 1
    fi
    
    # Find the top-level repository (superproject), not a submodule's root.
    local toplevel_repo
    toplevel_repo=$(git -C "$search_dir" rev-parse --show-toplevel)

    local superproject_repo
    superproject_repo=$(git -C "$toplevel_repo" rev-parse --show-superproject-working-tree 2>/dev/null)

    if [[ -n "$superproject_repo" ]]; then
        echo "$superproject_repo"
    else
        echo "$toplevel_repo"
    fi
}

commit_submodules() {
    local commit_message=$1
    local flag_file=$2
    local ai_commit=$3
    local ai_call_flag_file=$4
    local interactive_mode=$5
    print_step "Checking submodules for changes"
    
    export commit_message
    export LOG_FILE_PATH # Export for sub-shells
    export SCRIPT_DIR # Export SCRIPT_DIR for sub-shells
    export flag_file # Export the flag file path
    export ai_commit # Export AI flag
    export PROVIDER MODEL SLEEP_DURATION # Export AI config for subshell
    export COMMIT_SUFFIX
    export ai_call_flag_file
    export interactive_mode # Export interactive flag
    export -f log_message print_info print_success print_warning prompt_user_input

    if ! git submodule foreach --recursive '
        # We need to re-source utils because `git submodule foreach`
        # may not inherit all shell function contexts reliably.
        source "${SCRIPT_DIR}/utils/logging_utils.sh"
        source "${SCRIPT_DIR}/utils/messaging_utils.sh"

        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
            # SAFETY CHECK: Skip this submodule if ANY iCloud placeholders detected
            for filepath in $(git status --porcelain 2>/dev/null | grep "^ M" | cut -c4-); do
                if [ -f "$filepath" ]; then
                    file_type=$(file "$filepath" 2>/dev/null || echo "")
                    # Extract only the file type (after the colon) to avoid matching filenames
                    file_type_only=$(echo "$file_type" | cut -d: -f2-)
                    if echo "$file_type_only" | grep -q "empty"; then
                        print_warning "Skipping $name: iCloud placeholder detected ($filepath)"
                        echo "$name" >> "$skipped_submodules_file"
                        exit 0
                    fi
                fi
            done

            final_commit_message=""
            if [ "$ai_commit" = true ]; then
                print_info "Submodule $name has changes."

                # Conditionally sleep only if this is not the first AI call
                if [ -f "$ai_call_flag_file" ]; then
                    print_step "Sleeping for $SLEEP_DURATION seconds to avoid rate limiting..."
                    sleep "$SLEEP_DURATION"
                else
                    # First AI call, so set the flag for next time
                    touch "$ai_call_flag_file"
                fi

                print_info "Querying AI ($PROVIDER/$MODEL) for a commit message 🤖🧠"

                DIFF_CONTENT=$(git diff HEAD --stat)

                ai_error_file=$(mktemp)
                ai_output_file=$(mktemp)

                # The `if` statement allows us to check the exit code without `set -e` terminating the script.
                if ! vibe-tools ask "Generate a concise, conventional commit message starting with CHORE: for the following git diff: \`\`\`diff\n${DIFF_CONTENT}\n\`\`\`" --provider "$PROVIDER" --model "$MODEL" > "$ai_output_file" 2> "$ai_error_file"; then
                    print_warning "AI message generation failed for submodule $name."
                    print_error "$(cat "$ai_error_file")"
                    final_commit_message="CHORE: Automatic commit"
                else
                    # If vibe-tools succeeded, parse its output, escaping quotes for submodule context
                    final_commit_message=$(awk '\''/^CHORE:/ {print}'\'' "$ai_output_file")

                    if [ -z "$final_commit_message" ]; then
                        print_warning "AI did not return a valid conventional commit message for submodule $name. Falling back to default."
                        final_commit_message="CHORE: Automatic commit"
                    else
                        print_info "AI-generated message for $name: \"$final_commit_message\""

                        if [ "$interactive_mode" = true ]; then
                            prompt="Enter new message to override, or press Enter to accept"
                            final_commit_message=$(prompt_user_input "$prompt" "$final_commit_message")
                            print_info "Using message: \"$final_commit_message\""
                        fi
                    fi
                fi

                rm -f "$ai_error_file" "$ai_output_file"
            else
                final_commit_message="$commit_message"
            fi

            print_step "Committing changes in submodule $name"
            # CRITICAL: Do NOT use git add -u here!
            # git add -u only stages tracked files - if files become untracked
            # (iCloud sync issues, index corruption), they are treated as DELETIONS.
            # This caused catastrophic data loss on 2026-01-25.

            git add .
            git commit -m "${final_commit_message} ${COMMIT_SUFFIX}" --quiet
            print_success "Committed changes in submodule $name"
            echo "$name" >> "$flag_file" # Save the name of the committed submodule
        else
            print_warning "No changes to commit in submodule $name."
        fi
    ' 2>&1 | grep -v -e "^fatal: run_command" -e "^\.$"; then
        exit 1
    fi
}

commit_submodule_pointers() {
    local flag_file=$1

    export LOG_FILE_PATH # Export for sub-shells
    export SCRIPT_DIR # Export SCRIPT_DIR for sub-shells
    export flag_file # Export the flag file path
    export COMMIT_SUFFIX
    export -f log_message print_step print_info print_success print_warning

    print_step "Checking for submodule pointer updates"

    if ! git submodule foreach '
        # We need to re-source utils because `git submodule foreach`
        # may not inherit all shell function contexts reliably.
        source "${SCRIPT_DIR}/utils/logging_utils.sh"

        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
            # SAFETY CHECK: Skip this submodule if ANY iCloud placeholders detected
            for filepath in $(git status --porcelain 2>/dev/null | grep "^ M" | cut -c4-); do
                if [ -f "$filepath" ]; then
                    file_type=$(file "$filepath" 2>/dev/null || echo "")
                    # Extract only the file type (after the colon) to avoid matching filenames
                    file_type_only=$(echo "$file_type" | cut -d: -f2-)
                    if echo "$file_type_only" | grep -q "empty"; then
                        print_warning "Skipping $name pointer update: iCloud placeholder detected ($filepath)"
                        echo "$name" >> "$skipped_submodules_file"
                        exit 0
                    fi
                fi
            done

            print_step "Committing submodule pointer updates in $name"
            # CRITICAL: Do NOT use git add -u here! See comment in commit_submodules().

            git add .
            git commit -m "CHORE: Update submodule pointers ${COMMIT_SUFFIX}" --quiet
            print_success "Committed submodule pointer updates in $name"
            echo "$name" >> "$flag_file" # Save the name of the committed submodule
        fi
    ' 2>&1 | grep -v -e "^fatal: run_command" -e "^\.$"; then
        exit 1
    fi

}

commit_parent_repo() {
    local commit_message=$1
    local ai_commit=$2
    local ai_call_flag_file=$3
    local interactive_mode=$4
    print_info "Checking parent repository for changes"

    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        # SAFETY CHECK: Abort IMMEDIATELY if ANY iCloud placeholders detected
        for filepath in $(git status --porcelain 2>/dev/null | grep "^ M" | cut -c4-); do
            if [ -f "$filepath" ]; then
                file_type=$(file "$filepath" 2>/dev/null || echo "")
                # Extract only the file type (after the colon) to avoid matching filenames
                file_type_only=$(echo "$file_type" | cut -d: -f2-)
                if echo "$file_type_only" | grep -q "empty"; then
                    print_error "SAFETY ABORT: iCloud placeholder detected in parent repo: $filepath"
                    print_error "Cannot commit - data loss risk. Files must be downloaded from iCloud first."
                    exit 1
                fi
            fi
        done

        final_commit_message=""
        if [ "$ai_commit" = true ]; then

            print_info "Parent repo has changes."

            # Conditionally sleep only if this is not the first AI call
            if [ -f "$ai_call_flag_file" ]; then
                print_step "Sleeping for $SLEEP_DURATION seconds to avoid rate limiting..."
                sleep "$SLEEP_DURATION"
            else
                # First AI call, so set the flag for next time
                touch "$ai_call_flag_file"
            fi

            print_info "Querying AI ($PROVIDER/$MODEL) for a commit message 🤖🧠"

            DIFF_CONTENT=$(git diff HEAD --stat)
            
            local ai_error_file
            ai_error_file=$(mktemp)
            local ai_output_file
            ai_output_file=$(mktemp)

            # The `if` statement allows us to check the exit code without `set -e` terminating the script.
            if ! vibe-tools ask "Generate a concise, conventional commit message starting with CHORE: for the following git diff: \`\`\`diff\n${DIFF_CONTENT}\n\`\`\`" --provider "$PROVIDER" --model "$MODEL" > "$ai_output_file" 2> "$ai_error_file"; then
                print_warning "AI message generation failed for parent repo."
                print_error "$(cat "$ai_error_file")"
                final_commit_message="CHORE: Automatic commit"
            else
                # If vibe-tools succeeded, parse its output
                final_commit_message=$(awk '/^CHORE:/ {print}' "$ai_output_file")

                if [ -z "$final_commit_message" ]; then
                    print_warning "AI did not return a valid conventional commit message for parent repo. Falling back to default."
                    final_commit_message="CHORE: Automatic commit"
                else
                    print_info "AI-generated message for parent: \"$final_commit_message\""
                    if [ "$interactive_mode" = true ]; then
                        prompt="Enter new message to override, or press Enter to accept"
                        final_commit_message=$(prompt_user_input "$prompt" "$final_commit_message")
                        print_info "Using message: \"$final_commit_message\""
                    fi
                fi
            fi

            rm -f "$ai_error_file" "$ai_output_file"
        else
            final_commit_message="$commit_message"
        fi

        print_step "Committing changes in the parent repository"
        # CRITICAL: Do NOT use git add -u here! See comment in commit_submodules().

        git add .
        git commit -m "${final_commit_message} ${COMMIT_SUFFIX}" --quiet
        print_success "Committed changes in the parent repository."
        return 0 # Indicate a commit was made
    else
        print_warning "No changes to commit in the parent repository."
        return 1 # Indicate no commit was made
    fi
}

push_changes() {
    print_step "Pushing all changes to the remote"

    print_step "Step 1: Pushing changes in submodules"
    if ! git submodule foreach 'git push --quiet' 2>&1 | grep -v -e "^fatal: run_command" -e "^\.$" >&2; then
        print_error "Failed to push one or more submodules."
        print_warning "Aborting parent repository push to prevent inconsistent state."
        exit 1
    fi
    print_success "All submodules pushed successfully."

    print_step "Step 2: Pushing changes in parent repository"
    if ! git push --quiet >&2; then
        print_error "Failed to push the parent repository. Please check your remote configuration and the output above."
        exit 1
    fi
    print_success "Parent repository pushed successfully."
    
    print_success "All changes have been pushed to the remote."
}

# --- Script Entrypoint ---
run_commit_workflow() {
    ensure_log_directory

    local commit_message=""
    local push_parent_only=false
    local push_all=false
    local directory_arg=""
    local ai_commit=false
    local remaining_args=()
    local parent_committed=false
    local submodule_flag_file
    local committed_submodules=() # Array to hold names
    local timestamp
    local COMMIT_SUFFIX
    local ai_call_flag_file=""

    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    # The suffix is constructed here and will be available to all functions
    COMMIT_SUFFIX="${COMMIT_MESSAGE_SUFFIX_TEMPLATE} @ ${timestamp}"
    export COMMIT_SUFFIX

    # Manual parsing to allow flexible argument order
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -m)
                if [[ -n "$2" ]]; then
                    commit_message="$2"
                    shift 2
                else
                    print_error "Option -m requires an argument."
                    usage
                    exit 1
                fi
                ;;
            -a|--ai-commit)
                ai_commit=true
                shift
                ;;
            -i|--interactive)
                INTERACTIVE_MODE=true
                shift
                ;;
            -p)
                if [[ -n "${2-}" && "$2" == "all" ]]; then
                    push_all=true
                    shift 2
                else
                    push_parent_only=true
                    shift
                fi
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -* )
                print_error "Invalid option: $1" >&2
                usage
                exit 1
                ;;
            *)
                remaining_args+=("$1") # Save it in an array for later
                shift
                ;;
        esac
    done

    print_header "DLS Submodules Commit Workflow"

    # The remaining argument should be the directory, if provided.
    if [ "${#remaining_args[@]}" -gt 1 ]; then
        print_error "Error: Too many directory arguments specified."
        usage
        exit 1
    fi
    
    if [ "${#remaining_args[@]}" -eq 1 ]; then
        directory_arg="${remaining_args[0]}"
    fi

    if [ "$ai_commit" = true ]; then
        load_config
        if [ -z "${MODEL:-}" ]; then
            print_error "AI commits are enabled, but no model is configured in 'scripts/vibe.config'."
            print_error "Please set MODEL to your desired model to use this feature."
            print_error "Aborting to prevent unexpected costs."
            exit 1
        fi
        check_ai_dependencies
        ai_call_flag_file=$(mktemp)
        # Immediately remove the file; we only need the unique name to use as a flag
        rm -f -- "$ai_call_flag_file"
    fi

    if [ "$ai_commit" = true ] && [ -n "$commit_message" ]; then
        print_warning "Both --ai-commit and -m flags were used. Ignoring -m and using AI-generated messages."
    fi

    if [ "$ai_commit" = false ] && [ -z "$commit_message" ]; then
        commit_message="CHORE: Automatic commit"
        print_warning "No commit message provided. Using default: '$commit_message'"
    fi

    local target_dir
    if [[ -n "$directory_arg" ]]; then
        if [[ ! -d "$directory_arg" ]]; then
            print_error "Directory not found: $directory_arg"
            usage
            exit 1
        fi
        target_dir="$(cd "$directory_arg" && pwd)"
    else
        target_dir="$(pwd)"
        log_message "INFO" "No directory specified. Using current directory: ${target_dir}"
    fi

    local repo_root
    repo_root=$(find_repo_root "$target_dir")
    
    cd "$repo_root"
    print_info "Operating in repository: $repo_root"

    submodule_flag_file=$(mktemp)
    # Global file to track all skipped submodules across all operations
    local skipped_submodules_file
    skipped_submodules_file=$(mktemp)
    export skipped_submodules_file

    # Ensure temp files are cleaned up on exit. Handles cases where they might not be created.
    trap '
        [[ -n "${submodule_flag_file:-}" ]] && rm -f -- "$submodule_flag_file"
        [[ -n "${skipped_submodules_file:-}" ]] && rm -f -- "$skipped_submodules_file"
        [[ -n "${ai_call_flag_file:-}" ]] && rm -f -- "$ai_call_flag_file"
    ' EXIT

    commit_submodules "$commit_message" "$submodule_flag_file" "$ai_commit" "$ai_call_flag_file" "$INTERACTIVE_MODE"
    
    # Second pass: commit any submodule pointer updates created by the first pass
    commit_submodule_pointers "$submodule_flag_file"
    
    # Read the names of committed submodules from the flag file into an array
    if [ -s "$submodule_flag_file" ]; then
        while IFS= read -r line; do
            committed_submodules+=("$line")
        done < "$submodule_flag_file"
    fi

    if commit_parent_repo "$commit_message" "$ai_commit" "$ai_call_flag_file" "$INTERACTIVE_MODE"; then
        parent_committed=true
    fi
    
    if [ "$push_all" = true ]; then
        push_changes
    elif [ "$push_parent_only" = true ]; then
        print_step "Pushing changes in parent repository only"
        if ! git push --quiet >&2; then
            print_error "Failed to push the parent repository. Please check your remote configuration and the output above."
            exit 1
        fi
        print_success "Parent repository pushed successfully."
    fi

    print_separator

    # Show summary of ALL skipped submodules (from both commit and pointer operations)
    if [ -s "$skipped_submodules_file" ]; then
        echo ""
        print_warning "========================================"
        print_warning "SKIPPED SUBMODULES (iCloud placeholders)"
        print_warning "========================================"

        # Use sort -u to deduplicate (a submodule could be skipped in both operations)
        sort -u "$skipped_submodules_file" | while IFS= read -r submodule_name; do
            print_warning "  ✗ $submodule_name"
        done

        print_warning ""
        print_warning "These submodules were not committed due to iCloud placeholders."
        print_warning "Fix: Run 'brctl download .' in each submodule directory, then re-run this script."
        echo ""
    fi

    print_completed "Commit workflow complete."

    local push_action_desc="No push was performed."
    if [ "$push_all" = true ]; then
        push_action_desc="Pushed all submodules and parent repository."
    elif [ "$push_parent_only" = true ]; then
        push_action_desc="Pushed parent repository only."
    fi

    local submodules_committed_desc="None"
    if [ ${#committed_submodules[@]} -gt 0 ]; then
        # Join array elements with a comma for display
        submodules_committed_desc=$(IFS=', '; echo "${committed_submodules[*]}")
    fi

    local parent_committed_desc="No"
    if [ "$parent_committed" = true ]; then
        parent_committed_desc="Yes"
    fi

    commit_mode_desc="Manual (pre-defined message)"
    if [ "$ai_commit" = true ]; then
        commit_mode_desc="AI-Generated"
    fi

    print_info "Commit Summary:"
    print_info "  - Commit Mode:           ${commit_mode_desc}"
    if [ "$ai_commit" = false ]; then
        print_info "  - Message:               \"${commit_message}\""
    fi
    print_info "  - Committed Submodules:  ${submodules_committed_desc}"
    print_info "  - Parent Repo Committed: ${parent_committed_desc}"
    print_info "  - Push Action:           ${push_action_desc}"

    print_footer

    # Exit with error if any submodules were skipped
    if [ -s "$skipped_submodules_file" ]; then
        exit 1
    fi 
}

main() {
    (
        if ! flock -n 200; then
            # The messaging utils are already sourced globally,
            # so we can use print_error directly.
            print_error "Another instance of dls-commit-all.sh is already running."
            exit 1
        fi
        
        check_dependencies
        
        run_commit_workflow "$@"

    ) 200>"${LOCK_FILE}"
}

main "$@" 