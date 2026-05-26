# shellcheck shell=bash

# this hook allows specifying extensions that should be (ephemerally) installed
# for any ambient vscode install. it does this by wrapping the ambient vscode
# executable to make it use a synthetic profile containing the extensions
# specified in `vscodeExtensions`.
#
# extensions are specifically targeted because settings, debugger profiles, and
# tasks can already be scoped to a specific workspace, but not the extensions
# they configure or depend on.
# if you need to configure settings or tasks for a workspace, you can already
# do that by putting regular files in `.vscode/`. if you need them to, for
# example, contain references to stuff from the nix store, you can generate
# these files "on the fly" with mkShell's `shellHook` argument.
#
# an explicit goal of this hook is to avoid forcing the user to add vscode
# to the devshell, so that it doesn't bloat up the closure size for those
# who don't use vscode. for now the _extensions_ are added to the closure, but
# since they are generally just balls of javascript, they don't tend to weigh
# quite as much and generally have no dependencies.
# hopefully this restriction explains some of the weird choices i have made
# (such as writing most of this in bash instead of nix...)

main() {
    # if there are no vscodeExtensions specified
    if [[ ! -v vscodeExtensions ]] || [[ -z "${vscodeExtensions[*]}" ]]; then
        echo "warn: vscodeProfileHook used, but no vscodeExtensions were actually specified"
        return
    fi

    # 1. put all the extensions from `$vscodeExtensions` into a temp folder
    echo "${vscodeExtensions[@]}"
    mkdir -p "${TMPDIR:-$TMP}/vscode-extensions"

    # 2. get base user extensions, making sure not to overwrite devshell-specified ones

    # 3. add exts from $vscodeExtensions to the existing `extensions.json` file

    # 4. generate vscode wrapper (note: with correct argv0!) and put it in the temp folder

    # 5. add temp folder to PATH, as an export
}

main
