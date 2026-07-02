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
    local ext ext_dir ext_name
    local variant="$1"

    # if there are no vscodeExtensions specified
    if [[ -z "${vscodeExtensions:-}" ]]; then
        # shellcheck disable=SC2016 # those are markdown-style backticks, not a subshell
        echo -e '\e[1;33mWARN\e[0;33m[vscode-ext-hook]\e[0m: vscode-ext-hook used, but `vscodeExtensions` was empty or unset'
        return
    fi

    # 1. create a temp folder and start adding base user extensions to it
    ext_dir="${TMPDIR:-$TMP}/$variant-extensions"
    mkdir -p -- "$ext_dir"

    for ext in "$HOME/.$variant/extensions/"*; do
        ext_name="$(stripVersion "$(basename "$ext")")"
        # don't copy the old extensions.json
        if [[ "$ext_name" = "extensions.json" ]]; then
            continue
        fi

        # if we've already installed an extension with that name,
        # that means the user has a somewhat broken setup with duplicate
        # extensions... just silently skip installing them
        if [[ -e "$ext_dir/$ext_name" ]]; then
            continue
        fi

        ln -s -- "$ext" "$ext_dir/$ext_name"
        generateSingleManifest "$ext_dir/$ext_name" \
            > "$ext_dir/$ext_name.manifest.json" \
        || echo -e "\e[1;33mWARN\e[0;33m[vscode-ext-hook]\e[0m: couldn't parse package.json of user-installed extension \e[1m'$ext_name'\e[0m (is it corrupted?), skipping" >&2
    done

    # 2. put all the extensions from `$vscodeExtensions` into the temp folder,
    #    overwriting base ones if they already exist

    # note: unfortunately, mkShell does not have structuredAttrs by default,
    #       so if `__structuredAttrs` is not set, we need to wordsplit ourselves
    if (( ! ${__structuredAttrs:-0} )); then
        read -ra vscodeExtensions <<< "$vscodeExtensions"
    fi

    for ext in "${vscodeExtensions[@]}"; do
        # ugly workaround for bash not expanding globs when expected
        ext_=("$ext/share/vscode/extensions/"*)
        ext="${ext_[0]}"

        ext_name="$(stripVersion "$(basename "$ext")")"

        if [[ -e "$ext_dir/$ext_name" ]]; then
            echo -e "\e[1;33mWARN\e[0;33m[vscode-ext-hook]\e[0m: in this shell, the nix-shell-provided extension \e[1m'$ext_name'\e[0m will take precedence over user-installed version" >&2
            rm "$ext_dir/$ext_name"
        fi

        ln --force -s -- "$ext" "$ext_dir/$ext_name"
        generateSingleManifest "$ext_dir/$ext_name" \
            > "$ext_dir/$ext_name.manifest.json"
    done

    # 3. generate the `extensions.json` file
    jq '.' \
        --slurp "$ext_dir"/*.manifest.json \
    > "$ext_dir/extensions.json"

    # 4. cleanup temporary manifests
    # rm "$ext_dir"/*.manifest.json

    # this is so dumb...
    # vscode tries to reuse the same extension host if two instances have the same
    # profile, even if they don't have the same extension dir.
    # to "fool" it into working correctly (i.e. starting a new extension host), we
    # have to "create a new profile" and start it using that; thankfully, vscode is
    # dumb enough to not see through symbolic links, so it's enough to just link to
    # the original profile, which has the advantage of making sure global changes
    # the user made in the wrapped vscode are persisted to their actual profile
    # 5. create link to default vscode user-data-dir
    ln -s "${XDG_CONFIG_HOME:-${HOME:-~}}/Code" "${TMPDIR:-$TMP}/Code" || true
}

# the stdenv one is defined after hooks run -_-
stripHash() {
    local strippedName casematchOpt=0
    # On separate line for `set -e`
    strippedName="$(basename -- "$1")"
    shopt -q nocasematch && casematchOpt=1
    shopt -u nocasematch
    if [[ "$strippedName" =~ ^[a-z0-9]{32}- ]]; then
        echo "${strippedName:33}"
    else
        echo "$strippedName"
    fi
    if (( casematchOpt )); then shopt -s nocasematch; fi
}

# this removes the version number and build info (e.g. platform), so that
# overwriting works correctly (e.g. we don't end up with foo-0.2 from the
# user and foo-0.3 from the shell)
stripVersion() {
    local ext_name
    ext_name="$(basename -- "$1")"
    echo "${ext_name%%-[0-9]*}"
}

# $1: extension directory
generateSingleManifest() {
    jq '(.publisher + "." + .name) as $extid |
{
    identifier: {
        id: $extid,
        uuid: ""
    },

    version: .version,

    relativeLocation: "'"$(basename "$1")"'",

    location: {
        "$mid": 1,
        fsPath: "'"$1"'",
        path: "'"$1"'",
        scheme: "file",
    },

    metadata: {
        id: "",
        publisherId: "",
        publisherDisplayName: .publisher,
        targetPlatform: "undefined",
        isApplicationScoped: false,
        updated: false,
        isPreReleaseVersion: false,
        installedTimestamp: 0,
        preRelease: 0
    }
}' "${1}/package.json"
}

if (( ! ${dontAddVscodeExtensions:-0} )); then
    main "vscode"     # vscode uses ~/.vscode
    main "vscode-oss" # vscodium uses ~/.vscode-oss
fi
