{
  curl,
  jq,
  lib,
  linkFarm,
  writeShellApplication,
}:
let
  wrapper = writeShellApplication {
    name = "vscode-extensions-wrapper.sh";
    text = builtins.readFile ./wrapper.sh;
    runtimeInputs = [ install-extension-wrapper ];
    inheritPath = true; # VERY important
  };

  hook = writeShellApplication {
    name = "vscode-extensions-hook.sh";
    text = builtins.readFile ./hook.sh;
    runtimeInputs = [ jq ];
    inheritPath = true; # VERY important
  };

  install-extension-wrapper = {
    name = "install-vscode-ext";
    text = builtins.readFile ./install-extension.sh;
    runtimeInputs = [ curl jq ];
    inheritPath = true;
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
