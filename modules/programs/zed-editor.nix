{ ... }:
{
  flake.modules.nixos.zed-editor =
    { pkgs, ... }:
    {
      # Install nixd LSP system-wide
      environment.systemPackages = with pkgs; [ nixd ];
      # Install zed-editor at user-level via hjem
      hj.packages = with pkgs; [ zed-editor ];

      # Dynamic library support
      programs.nix-ld.enable = true;
    };
}
