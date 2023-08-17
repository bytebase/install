#!/bin/sh

# Users can execute this script to uninstall the bytebase installed by install.sh.

set -u

abort() {
    printf "%s\n" "$@" >&2
    exit 1
}

have_sudo_access() {
    if [ ! -x "/usr/bin/sudo" ]; then
        return 1
    fi
}

realpath() {
    cd "$(dirname "$1")" && echo "$(pwd -P)/$(basename "$1")"
}

resolved_pathname() {
    realpath "$1"
}

pretty_print_pathnames() {
    path
    for path in "$@"; do
        if [ -L "${path}" ]; then
            printf '%s -> %s\n' "${path}" "$(resolved_pathname "${path}")"
        elif [ -d "${path}" ]; then
            echo "${path}/"
        else
            # other files
            echo "${path}"
        fi
    done
    echo ""
}

read_confirm() {
    input
    if [ "${NONINTERACTIVE-}" != "1" ]; then
        read -rp "${1} [y/other] " input
        [[ "${input}" == [yY]* ]] || abort
    fi
}

execute() {
    need_delete=(
        "/opt/bytebase"
        "/usr/local/bin/bytebase"
        "/usr/local/bin/bb"
    )

    echo "The following Bytebase files or directories will be removed:"
    pretty_print_pathnames ${need_delete[@]}

    read_confirm "Are you sure you want to uninstall bytebase? This will remove the files or directories above!"

    path
    for path in ${need_delete[@]}; do
        if [ -d "${path}" ]; then
            sudo rm -r "$(resolved_pathname "${path}")"
        else
            sudo rm "$(resolved_pathname "${path}")"
        fi
    done

    echo "Uninstall bytebase and bb successfully!"
}

execute
