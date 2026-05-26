# shellcheck shell=bash

# dry-run mktemp to get the same path as the setup hook
ext_dir="${TMPDIR:-$TMP}/vscode-extensions"

if [[ ! -d "$ext_dir" ]]; then
    echo "ERROR: vscode setup hook didn't create extension folder" > /dev/stderr
    exit 1
fi

# remove ourselves from the PATH, so that we don't recursively invoke the wrapper
# when trying to launch the real vscode/vscodium
our_path="$(realpath "$(dirname -- "${BASH_SOURCE[0]}")")"
PATH=":$PATH:"
PATH="${PATH//:$our_path:/:}"
PATH="${PATH#:}"
PATH="${PATH%:}"

exec "$(basename "$0")" --extension-dir "$ext_dir"

