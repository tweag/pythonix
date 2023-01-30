{
  nixpkgs ? fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/1badc6db75d797f53c77d18d89c4eb8616d205cc.tar.gz";
    sha256 = "0rwrlfgwhb839r1vs08vbs80l99c2m7n7vvjb80kihvb3fy10wkb";
  },
  pkgs ? (import nixpkgs {}).pkgs
}:

with pkgs;

let
  filterMesonBuild = dir: builtins.filterSource
    (path: type: type != "directory" || baseNameOf path != "build") dir;
  python = python3;
in python.pkgs.buildPythonPackage rec {
  name = "pythonix";
  format = "other";

  nativeBuildInputs = [
    ninja
    (meson.override { python3 = python3; })
    pkgconfig
    gcc_latest
  ];

  doCheck = true;
  installCheckPhase = ''
    PYTHONPATH=$out/${python.sitePackages} NIX_STATE_DIR=$TMPDIR/var ninja test
  '';

  buildInputs = [ nix boost ];
  src = filterMesonBuild ./.;
}
