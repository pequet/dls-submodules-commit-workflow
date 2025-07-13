#!/bin/bash

# Standard Error Handling
set -e
set -u
set -o pipefail

# Logging Utilities
# Version: 1.0.0
# Author: Benjamin Pequet
# Projects: https://github.com/pequet/ 
# Purpose: Provides file-based logging utility functions.
# Refer to main project for detailed docs.

# --- Guard against direct execution ---
# This script provides utility functions and is not meant to be executed directly.
# It should be sourced by other DLS scripts.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script provides utility functions and is not meant to be executed directly." >&2
    echo "Please source it from another DLS script." >&2
    exit 1
fi

# --- Function Definitions ---

# *
# * Logging Functions
# *
# Handles all file-based logging operations.
# Expects the calling script to define:
#   - LOG_FILE_PATH: The full path to the log file.

ensure_log_directory() {
    local log_dir
    log_dir=$(dirname "${LOG_FILE_PATH}")
    if ! mkdir -p "${log_dir}"; then
        # This is a fatal error before logging is even possible. Echo directly.
        echo "FATAL: Cannot create log directory: ${log_dir}" >&2
        exit 1
    fi
}

log_message() {
    local type="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$(hostname)] [${type}] ${message}" >> "${LOG_FILE_PATH}"
} 