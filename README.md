# `vscode-ext-hook`

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

## Features

The two important features of this hook are:
- allowing the user to have their globally installed extensions alongside the
  shell-specified ones
- not adding vscode to the shell closure if it's not installed

That is, this hook is basically supposed to be a better implementation of the
seldom-used `.vscode/extensions.json` file. Eventually, I'd even like to
[use that file directly](https://github.com/blokyk/vscode-ext-hook/issues/1).

> [!NOTE]
> This is obviously impure and it's entirely possible there will be conflicts
> between extensions the user installed and ones you specified (e.g. clangd vs
> microsoft c/c++). However, in most cases this is still cleaner than installing
> new extensions globally just for a random project from a stranger.

> [!TIP]
> If you don't care about these features, you should use
> `pkgs.vscode-with-extensions`, which is a lot cleaner and more practical.

## Support

This should work with both vscode and vscodium; if on NixOS, both the normal and
the `-fhs` variants are supported, but **not** `pkgs.vscode-with-extensions` nor
`pkgs.vscode-utils.vscodeWithConfiguration` (they will _not_ work at all).

Note that unfortunately I only use vscode for now, so I can't ensure it'll
always keep working for vscodium. If you're a vscodium user, please open an
issue if it ever breaks, I'll get on it as quickly as possible!

Currently, only Linux is supported, not macOS. I have no idea if macOS works,
and I have no way to test it ¯\\\_(ツ)\_/¯

## Contributing

If you encounter any bug or have any question, don't hesitate to open an issue.
This is a side-side-side project, but I'll try to review PRs if any! (but please
no AI slop, [as it will be swiftly ignored](https://gist.github.com/blokyk/312a9c8f6fe8511e2f2358a416f1a3f2).)

[^1]: in reality, this also includes a small wrapper that gets added to the
PATH to run vscode/vscodium with the right extensions. this is due to an
unfortunate limitation of the intersection between setup hooks and `nix-shell`:
they can't easily change or even query the user's PATH, which is required to
override vscode if it exists. sucks :(
