set shell := ["/run/current-system/sw/bin/bash", "-uc"]

default:
  @just --list

up:
  nix flake update

switch:
  nh os switch . -H atlas

boot:
  nh os boot . -H atlas

switch-hydra:
  nixos-rebuild --target-host taylor@hydra --sudo --flake .#hydra switch

boot-hydra:
  nixos-rebuild --target-host taylor@hydra --sudo --flake .#hydra boot

switch-argon:
  nixos-rebuild --target-host taylor@argon --sudo --flake .#argon switch

boot-argon:
  nixos-rebuild --target-host taylor@argon --sudo --flake .#argon boot

switch-dns01:
  nixos-rebuild --target-host taylor@dns01 --sudo --flake .#dns01 switch

boot-dns01:
  nixos-rebuild --target-host taylor@dns01 --sudo --flake .#dns01 boot

switch-incus:
  nixos-rebuild --target-host taylor@incus --sudo --flake .#incus switch

boot-incus:
  nixos-rebuild --target-host taylor@incus --sudo --flake .#incus boot

bootstrap ip:
  nix run github:nix-community/nixos-anywhere -- --flake .#bootstrap --target-host root@{{ip}}
