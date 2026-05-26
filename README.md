# `devcode.nix`

A small `mkShell` setup hook[^1] to allow specifying vscode extensions to
have installed if the user has vscode.

The two important features of this hook are:
- alloing the user to have their globally installed
- not adding vscode to the shell closure if it's not installed

If you don't care about these features, you should use
`pkgs.vscode-with-extensions`, which is a lot cleaner and more practical.

> [!WARNING]
> Currently, Linux is supported, not macOS.

> [!WARNING]
> This will not work with `pkgs.vscode-with-extensions`, since it overrides the
> extension directory vscode uses, making the hook unable to get the user's
> usual extensions.

[^1]: in reality, this also includes a small wrapper that gets added to the
PATH to run vscode/vscodium with the right extensions. this is due to an
unfortunate limitation of the intersection between setup hooks and `nix-shell`:
they can't easily change or even query the user's PATH, which is required to
override vscode if it exists. sucks :(
