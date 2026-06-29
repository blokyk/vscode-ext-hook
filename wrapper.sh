# shellcheck shell=bash

if [[ "$0" = "codium" ]]; then
    ext_dir="${TMPDIR:-$TMP}/vscode-oss-extensions"
else
    ext_dir="${TMPDIR:-$TMP}/vscode-extensions"
fi

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

exec "$(basename "$0")" --extensions-dir "$ext_dir" --user-data-dir "${TMPDIR:-$TMP}/Code" "${@}"

