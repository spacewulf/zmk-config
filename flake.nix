{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      zmk-nix,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
    in
    {
      packages = forAllSystems (system: rec {
        default = firmware;

        firmware_dongle = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
          name = "firmware_dongle";

          parts = [
            "dongle"
          ];

          centralPart = "dongle";

          src = nixpkgs.lib.sourceFilesBySuffices self [
            ".board"
            ".cmake"
            ".conf"
            ".defconfig"
            ".dts"
            ".dtsi"
            ".json"
            ".h"
            ".keymap"
            ".overlay"
            ".shield"
            ".yml"
            "_defconfig"
          ];

          board = "xiao_ble//zmk";
          shield = "spacetyl_%PART%";

          zephyrDepsHash = "sha256-SPgBUgHDMlu7JDLfGQw/68CMnA/GKBHN+3qHp/QFRXY=";

          snippets = [
            "zmk-usb-logging"
          ];
        };

        firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
          name = "firmware";

          parts = [
            "left"
            "right"
            # "dongle"
          ];

          # centralPart = "dongle";

          src = nixpkgs.lib.sourceFilesBySuffices self [
            ".board"
            ".cmake"
            ".conf"
            ".defconfig"
            ".dts"
            ".dtsi"
            ".json"
            ".h"
            ".keymap"
            ".overlay"
            ".shield"
            ".yml"
            "_defconfig"
          ];

          board = "lemon_wireless";
          shield = "spacetyl_%PART%";

          zephyrDepsHash = "sha256-SPgBUgHDMlu7JDLfGQw/68CMnA/GKBHN+3qHp/QFRXY=";

          extraCmakeFlags = [
            "-DCONFIG_ZMK_SPLIT=y"
            "-DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n"
          ];
          # enableZmkStudio = true;
          # extraCmakeFlags = [
          #   "DSHIELD=settings_reset"
          # ];

          snippets = [
            "zmk-usb-logging"
          ];

          meta = {
            description = "ZMK firmware";
            license = nixpkgs.lib.licenses.mit;
            platforms = nixpkgs.lib.platforms.all;
          };
        };

        flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
        update = zmk-nix.packages.${system}.update;
      });

      devShells = forAllSystems (system: {
        default = zmk-nix.devShells.${system}.default;
      });
    };
}
