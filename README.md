# `nix-ext-hook`

A small `mkShell` setup hook[^1] to allow specifying vscode extensions to have
installed if the user has vscode/vscodium.

```nix
let
    pkgs = import <nixpkgs> { };
    # by default, vscode-ext-hook will use a pinned version of nixpkgs,
    # but you can also pass `pkgs = ...` if you want to override it
    vscode-ext-hook = pkgs.callPackage pins.vscode-ext-hook { };
in
pkgs.mkShell {
    packages = with pkgs; [
        clang-tools
        lldb
        nixd

        vscode-ext-hook
    ];

    vscodeExtensions = with pkgs.vscode-extensions; [
        llvm-vs-code-extensions.vscode-clangd
        llvm-vs-code-extensions.lldb-dap
        christian-kohler.path-intellisense
        jnoortheen.nix-ide
    ];
}
```

The two important features of this hook are:
- alloing the user to have their globally installed extensions alongside the
  shell-specified ones
- not adding vscode to the shell closure if it's not installed

Note that this is obviously impure and it's entirely possible there will be
conflicts between extensions the user installed and ones you specified (e.g.
clangd vs microsoft c/c++).

If you don't care about these features, you should use `pkgs.vscode-with-extensions`
(or other wrappers in `pkgs.vscode-utils`), which is a lot cleaner and more
practical.

> [!WARNING]
> This will not work with `pkgs.vscode-with-extensions`, since it overrides the
> extension directory vscode uses, making the hook unable to get the user's
> usual extensions.

This should work with both vscode and vscodium, but unfortunately I only use
vscode for now, so I can't ensure it'll always keep working for vscodium. If
you're a vscodium user, please open an issue if it ever breaks, I'll get on it
as quick as possible!

> [!WARNING]
> Currently, Linux is supported, not macOS. I have no idea if macOS works, and I
> have no way to test it ¯\\\_(ツ)\_/¯

[^1]: in reality, this also includes a small wrapper that gets added to the
PATH to run vscode/vscodium with the right extensions. this is due to an
unfortunate limitation of the intersection between setup hooks and `nix-shell`:
they can't easily change or even query the user's PATH, which is required to
override vscode if it exists. sucks :(
