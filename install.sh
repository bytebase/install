#!/bin/sh

# Users can install the latest version of bytebase by execute this script instead of cloning the whole bytebase GitHub repository and build by themselves.

set -eu

abort() {
    printf "%s\n" "$@" >&2
    exit 1
}

uname_os() {
    OS="$(uname -s)"
    if [ "${OS}" != "Darwin" ] && [ "${OS}" != "Linux" ]; then
        abort "OS ${OS} is not support, bytebase is only supported on Linux and MacOS"
    fi
    echo ${OS} | awk '{print tolower($0)}' 
}

uname_arch() {
    ARCH=$(uname -m)
    if [ "${ARCH}" = "amd64" ] || [ "${ARCH}" = "x86_64" ]; then
        ARCH="amd64"
    elif [ "${ARCH}" != "arm64" ]; then
        abort "Arch ${ARCH} is not support, bytebase is only supported on x86_64, amd64 and arm64"
    fi
    echo ${ARCH} | awk '{print tolower($0)}' 
}

http_download() {
    echo "Start downloading $2..."

    code=$(curl -w '%{http_code}' -L -o "$1" "$2")
    if [ "$code" != "200" ]; then
        abort "Failed to download from $2, status code: ${code}"
    fi

    echo "Completed downloading $2"
}

execute() {
    OS="$(uname_os)"
    echo "OS: ${OS}"
    ARCH="$(uname_arch)"
    echo "ARCH: ${ARCH}"

    install_dir="/usr/local/bin"

    tmp_dir=$(mktemp -d) || abort "cannot create temp directory"
    # Clean the tmpdir automatically if the shell script exit
    trap "rm -r ${tmp_dir}" EXIT

    echo "Downloading tarball into ${tmp_dir}"
    tarball_name="bytebase_${OS}_${ARCH}.tar.gz"
    echo ""
    url=$(curl -s https://api.github.com/repos/bytebase/bytebase/releases/latest | grep "http.*${tarball_name}" | cut -d : -f 2,3 | awk '{$1=$1};1' | tr -d \")
    http_download "${tmp_dir}/${tarball_name}" ${url}

    echo "Start extracting tarball into ${tmp_dir}..."
    cd "${tmp_dir}" && sudo tar -xzf "${tmp_dir}/${tarball_name}"

    sudo install "${tmp_dir}/bytebase" "${install_dir}"
    echo "Installed bytebase to ${install_dir}"
    sudo install "${tmp_dir}/bb" "${install_dir}"
    echo "Installed bb to ${install_dir}"
    echo ""
    echo "Check the usage with"
    echo "  bytebase --help"
    echo "  bb --help"
}

execute
