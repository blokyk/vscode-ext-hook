let pins = import ./npins {}; in
{
  pkgs ? import pins.nixpkgs {},
}:
let
  lib = pkgs.lib;

  wrapper = pkgs.writeShellApplication {
    name = "vscode-extensions-wrapper.sh";
    text = builtins.readFile ./wrapper.sh;
    inheritPath = true; # VERY important
  };

  hook = pkgs.writeShellApplication {
    name = "vscode-extensions-hook.sh";
    text = builtins.readFile ./hook.sh;
    runtimeInputs = [ pkgs.jq ];
    inheritPath = true; # VERY important
  };
in
pkgs.linkFarm "setup-vscode-extensions" [
  {
    name = "bin/code";
    path = lib.getExe wrapper;
  }
  {
    name = "bin/codium";
    path = lib.getExe wrapper;
  }
  {
    name = "nix-support/setup-hook";
    path = lib.getExe hook;
  }
]
