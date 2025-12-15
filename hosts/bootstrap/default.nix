{
  inputs,
  pkgs,
  private,
  ...
}:
{
  imports = [
    # 3rd party modules
    inputs.disko.nixosModules.disko
    ./hardware/disko.nix
    ./hardware/default.nix
  ];

  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "@wheel" ];
  };

  networking.hostName = "bootstrap";
  time.timeZone = "America/Chicago";

  users.users = {
    ${private.username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      hashedPassword = private.password;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;

  networking.firewall.enable = false;

  environment.systemPackages = with pkgs; [
    wget
    git
  ];

  # For bootstrapping
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable gnupg agent
  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  system.stateVersion = "24.11";

}
