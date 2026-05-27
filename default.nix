let pins = import ./npins {}; in
{
  pkgs ? import pins.nixpkgs {},
}:
pkgs.callPackage ./package.nix {}
