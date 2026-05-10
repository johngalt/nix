{ self, ... }:
{
  # Base profile which contains basic packages and modules
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      imports = with self.modules.nixos; [
        core # include core system settings

        # System modules
        hjem

        # Program modules
        helix
        git
        bat
        eza
      ];
      
      environment.systemPackages = with pkgs; [
        nano
        wget
        btop # TODO: Wrap btop with configuration?
        ncdu
        fastfetch
        duf
        fd
        fq
        jq
        ripgrep
        unzip
      ];
    };
}
