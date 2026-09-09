# Spacewulf's ZMK Config

## Basic Setup

This is my ZMK configuration for my custom Cosmos build. It features plenty of
features from a dongle to zmk-leader-key and zmk-unicode.

## Boards/Shields

The boards included here are the lemon_wireless/nrf52840 and the xiao_ble//zmk,
the former for the splits and the latter for the dongle.

## Building

This branch of my `zmk-config` is built using a nix devshell, along with direnv.
To build it, make sure you have nix installed and flakes enabled, as well as
nix-direnv hooked in to your shell. Once you've done that, enter the directory
and type `direnv allow`, which will start to pull dependencies, followed by a
`just init` to fetch all of the dependencies. Once that has completed, run
`just build all` to build the firmware.
