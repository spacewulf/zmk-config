{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    zephyr.url = "github:zmkfirmware/zephyr/v4.1.0+zmk-fixes";
    zephyr.flake = false;

    zephyr-nix.url = "github:nix-community/zephyr-nix";
    zephyr-nix.inputs.zephyr.follows = "zephyr";
    zephyr-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Devicetree linter; use my fork for nix-package and ZMK-specific tweaks.
    dts-linter.url = "github:urob/dts-linter/zmk";
    dts-linter.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    {
      nixpkgs,
      zephyr-nix,
      dts-linter,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          zephyr = zephyr-nix.packages.${system};
          keymap_drawer = pkgs.python3Packages.callPackage ./nix/keymap-drawer.nix { };
          dts-format = pkgs.callPackage ./nix/dts-format.nix {
            dts-linter = dts-linter.packages.${system}.dev;

          };
        in
        {
          default = pkgs.mkShellNoCC {
            packages = [
              zephyr.pythonEnv
              (zephyr.sdk-0_16.override { targets = [ "arm-zephyr-eabi" ]; })

              pkgs.cmake
              pkgs.dtc
              pkgs.gcc
              pkgs.ninja

              pkgs.just
              pkgs.yq

              keymap_drawer
              dts-format
            ];

            env = {
              PYTHONPATH = "${zephyr.pythonEnv}/${zephyr.pythonEnv.sitePackages}";
            };

            shellHook = ''
              export ZMK_BUILD_DIR=$(pwd)/.build;
              export ZMK_SRC_DIR=$(pwd)/zmk/app;
            ''
            + (
              if pkgs.stdenv.isLinux then
                let
                  libatomic = pkgs.runCommand "libatomic" { } ''
                    mkdir -p $out/lib
                    cp -d ${pkgs.stdenv.cc.cc.lib}/lib/libatomic.so* $out/lib/
                  '';
                in
                ''
                  export LD_LIBRARY_PATH="${libatomic}/lib";
                ''
              else
                ""
            );

          };
        }
      );
    };

}
