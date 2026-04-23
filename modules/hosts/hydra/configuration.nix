# VM Configuration. To build/deploy on incus:
# > nix build .#nixosConfigurations.test.config.system.build.qemuImage --print-out-paths
# > nix build .#nixosConfigurations.test.config.system.build.metadata --print-out-paths
# > incus image import --alias test \
#  /nix/store/8c5f962ngpclwjj9w1xcr48w9rccskqk-tarball/tarball/nixos-image-lxc-metadata-26.05.20260414.4bd9165-x86_64-linux.tar.xz \
#  /nix/store/pxswjzpgw0iwaxvyrvhcbik371mnalmj-nixos-disk-image/nixos.qcow2
# > incus launch test
#
# WILL NOT BE ABLE TO USE SOPS UNTIL HOSTKEY IS ADDED TO AGE FILE.
# Have to set user password, can use `incus shell test` to login to shell
{ self, ... }:
{
  flake.modules.nixos."hosts/hydra" =
    { private, config, ... }:
    {
      imports = with self.modules.nixos; [
        # Profiles
        core
        server
        incus-vm
      ];

      # Initialize secrets
      sops.secrets."renovate/github_key" = { };
      sops.secrets."renovate/renovate_key" = { };

      services.renovate = {
        enable = true;
        credentials = {
          RENOVATE_TOKEN = config.sops.secrets."renovate/renovate_key".path;
          GITHUB_COM_TOKEN = config.sops.secrets."renovate/github_key".path;
        };
        settings = {
          endpoint = "https://forge.${private.domain}/api/v1";
          gitAuthor = "Renovate Bot <renovate-bot@${private.domain}>";
          platform = "forgejo";
          onboardingConfigFileName = "renovate.json";
          autodiscover = true;
          optimizeForDisabled = true;
          persistRepoData = true;
        };
        schedule = "*-*-* 00/2:00:00";
      };

      nixpkgs.hostPlatform = "x86_64-linux";
    };
}
