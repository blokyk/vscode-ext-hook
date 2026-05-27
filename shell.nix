let
  pins = import ./npins {};
  pkgs = import pins.nixpkgs {};
  vscode-ext-hook = import ./default.nix {};
in
pkgs.mkShell {
  packages = [
    vscode-ext-hook
  ];

  vscodeExtensions = with pkgs.vscode-extensions; [
    christian-kohler.path-intellisense
    jnoortheen.nix-ide
  ];
}
