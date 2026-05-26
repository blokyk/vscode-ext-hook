let
  pins = import ./npins {};
  pkgs = import pins.nixpkgs {};
  vscodeProfileHook = import ./default.nix {};
in
pkgs.mkShell {
  packages = [
    vscodeProfileHook
  ];

  vscodeExtensions = with pkgs.vscode-extensions; [
    christian-kohler.path-intellisense
    jnoortheen.nix-ide
    dart-code.flutter
  ];

  shellHook = ''
    # echo "$PATH"
  '';
}
