# Spacewulf's ZMK Config

## Basic Setup

This is my ZMK configuration for my custom Cosmos build. It features plenty of
features from a dongle to zmk-leader-key and zmk-unicode.

## Boards/Shields

The boards included here are the lemon_wireless/nrf52840 and the xiao_ble//zmk,
the former for the splits and the latter for the dongle.

## Building

This branch uses a nix toolchain featured
[here](https://github.com/lilyinstarlight/zmk-nix). Run `nix build` to build the
firmware. Note, I have not tested this currently with the dongle, as that has to
be compiled separately using `nix build .#firmware_dongle`, as the original
toolchain does not provide a method for compiling firmware for different boards
at the same time.
