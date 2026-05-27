{
  jq,
  lib,
  linkFarm,
  writeShellApplication,
}:
let
  wrapper = writeShellApplication {
    name = "vscode-extensions-wrapper.sh";
    text = builtins.readFile ./wrapper.sh;
    inheritPath = true; # VERY important
  };

  hook = writeShellApplication {
    name = "vscode-extensions-hook.sh";
    text = builtins.readFile ./hook.sh;
    runtimeInputs = [ jq ];
    inheritPath = true; # VERY important
  };
in
linkFarm "vscode-ext-hook" [
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
