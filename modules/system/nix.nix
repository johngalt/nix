{
  lib,
  config,
  inputs,
  ...
}:
{
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  # FLAKE FIXES
  # Set PATH to use this flakes nixpkgs rather than download from github
  # when using nix shell nixpkgs#test and other commands
  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        trusted-users = [ "@wheel" ];
        # Opinionated: disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;

        download-buffer-size = 524288000;
      };
      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 20d";
        persistent = true;
      };
      optimise = {
        automatic = true;
        persistent = true;
      };

    };

  time = {
    timeZone = "America/Chicago";
    hardwareClockInLocalTime = lib.mkDefault true;
  };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
