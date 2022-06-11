#!/bin/sh

# Users can execute this script to uninstall the bytebase installed by install.sh.

set -u

abort() {
    printf "%s\n" "$@" >&2
    exit 1
}

have_sudo_access() {
    if [[ ! -x "/usr/bin/sudo" ]]; then
        return 1
    fi
}

resolved_pathname() {
    realpath "$1"
}

pretty_print_pathnames() {
    local path
    for path in "$@"; do
        if [[ -L "${path}" ]]; then
            printf '%s -> %s\n' "${path}" "$(resolved_pathname "${path}")"
        elif [[ -d "${path}" ]]; then
            echo "${path}/"
        else
            # other files
            echo "${path}"
        fi
    done
}

execute() {
    local need_delete=(
        "/opt/bytebase"
        "/usr/local/bin/bytebase"
        "/usr/local/bin/bb"
    )

    echo "The following Bytebase files or directories will be removed:"
    pretty_print_pathnames ${need_delete[@]}

    local path
    for path in ${need_delete[@]}; do
        if [[ -d "${path}" ]]; then
            sudo rm -r "$(resolved_pathname "${path}")"
        else
            sudo rm "$(resolved_pathname "${path}")"
        fi
    done

    echo "Uninstall bytebase and bb successfully!"
}

execute
