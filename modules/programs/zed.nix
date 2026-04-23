{ ... }:
{
  flake.modules.nixos.zed =
    { pkgs, ... }:
    {
      # Install nixd LSP system-wide
      environment.systemPackages = with pkgs; [ nixd ];
      # Install zed-editor at user-level via hjem
      hj.packages = with pkgs; [ zed-editor ];

      # Dynamic library support
      programs.nix-ld.enable = true;

      # Set home directories to persist if enabled
      custom.system.impermanence = {
        persistHome.directories = [
          ".config/zed"
          ".local/share/zed"
        ];
      };
    };
}
