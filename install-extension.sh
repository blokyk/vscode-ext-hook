#!/bin/bash
# https://sunshaoce.gallery.vsassets.io/_apis/public/gallery/publisher/sunshaoce/extension/llvmmir/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage

if ! [[ -v 1 ]]; then
    echo -e "\e[1musage:\e[0m $0 <publisher.extname>"
    exit 1
fi

ext_name="$1"

if ! [[ "$ext_name" =~ [A-Za-z0-9-_].[A-Za-z0-9-_] ]]; then
    echo -e '\e[1;31merror:\e[0m extension name must be in the format \e[1m'publisher.ext-name'\e[0m'
    exit 1
fi

req='{
  "assetTypes": [],
  "filters": [
    {
      "criteria": [
        {
          "filterType": 7,
          "value": "'"$ext_name"'"
        }
      ],
      "pageNumber": 1,
      "pageSize": 1
    }
  ],
  "flags": 1
}'

data="$(\
    curl \
        --header 'Accept: application/json;api-version=3.0-preview.1' \
        --header 'Content-Type: application/json' \
        https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery \
        --data "$req" \
        -o - \
    | jq '.results[0].extensions[0]'
)"

if [[ "$data" = "null" ]]; then
    echo -e "\e[1;31merror:\e[0m extension \e[1m'$ext_name'\e[0m not found"
    exit 1
fi

publisher="$(echo "$data" | jq '.publisher.publisherName')"
name="$(echo "$data" | jq '.extensionName')"
version="$(echo "$data" | jq '.versions[0].version')"

# todo: check `vscode-extensions.$publisher.$version` first

hash="$(\
    nix-prefetch-url --name "sunshaoce-llvmmir.vsix" \
        "https://$publisher.gallery.vsassets.io/_apis/public/gallery/publisher/$publisher/extension/$name/$version/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage" \
)"
sri="$(nix-hash --to-base64 --type sha256 "$hash")"

# we output the user-directed messages to stderr and the actual nix code to stdout
# to make it easier to use programmatically
echo -e 'To add an extension to this nix shell, you can use the following declaration (e.g. with \e[3mvscode-utils.extensionFromVscodeMarketplace\e[0m)' >&2
echo '{ publisher = "'$publisher'"; name = "'$name'"; version = "'$version'"; sha256 = "'$sri'"; }'
