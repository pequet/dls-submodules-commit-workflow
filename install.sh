#!/bin/bash

# Standard Error Handling
set -e
set -u
set -o pipefail

# Author: Benjamin Pequet
# Purpose: Installs the dls-commit-all.sh script for global use.
# Project: https://github.com/pequet/dls-submodules-commit-workflow/
# Refer to main project for detailed docs.

# --- Helper Functions for printing messages ---
print_header() {
    echo "================================================="
    echo " $1"
    echo "================================================="
}

print_step() {
    echo "--> $1"
}

print_success() {
    echo "✔ $1"
}

print_error() {
    echo "✖ $1" >&2
}

print_info() {
    echo "  $1"
}

print_separator() {
    echo "-------------------------------------------------"
}

# --- Main Installation Logic ---
main() {
    print_header "DLS Submodules Commit Workflow Installer"

    # --- Define Paths ---
    local INSTALL_SCRIPT_DIR
    INSTALL_SCRIPT_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    local SOURCE_SCRIPT_NAME="dls-commit-all.sh"
    local DEST_DIR="/usr/local/bin"
    local DEST_PATH="${DEST_DIR}/${SOURCE_SCRIPT_NAME}"
    local SOURCE_SCRIPT_PATH="${INSTALL_SCRIPT_DIR}/scripts/${SOURCE_SCRIPT_NAME}"

    # --- Step 1: Verify source file ---
    print_step "Step 1: Verifying required script"
    if [ ! -f "$SOURCE_SCRIPT_PATH" ]; then
        print_error "Source script not found at ${SOURCE_SCRIPT_PATH}"
        exit 1
    fi

    # --- Step 2: Verify destination directory ---
    print_step "Step 2: Verifying destination directory"
    if [ ! -d "$DEST_DIR" ]; then
        print_error "Destination directory ${DEST_DIR} not found."
        print_info "Please ensure standard Homebrew/macOS paths are configured."
        exit 1
    fi

    # --- Step 3: Install the main script ---
    print_step "Step 3: Installing the main script"
    print_info "This will make the '${SOURCE_SCRIPT_NAME}' command available globally."
    print_info "You may be prompted for your administrator password."

    if ! sudo ln -sf "$SOURCE_SCRIPT_PATH" "$DEST_PATH"; then
        print_error "Failed to create symbolic link. Please check permissions for ${DEST_DIR}."
        exit 1
    fi

    print_separator
    print_success "Success!"
    print_info "The '${SOURCE_SCRIPT_NAME}' command is now installed."
    print_info "You can now run it from any directory."
    print_info "Example: dls-commit-all.sh \"Your commit message\""

}

# --- Script Entrypoint ---
main "$@" 