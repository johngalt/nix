{ self, ... }:
{
  flake.modules.nixos.server =
    { pkgs, lib, private, ... }:
    {
      imports = with self.modules.nixos; [
        beszel
      ];

      config = {
        # Going to override default shell on servers since some remote tools don't like fish
        users.users.${private.username}.shell = lib.mkForce pkgs.bash;
        # Will start fish on interactive shells instead
        programs.bash.interactiveShellInit = ''
          exec fish
        '';

        # Needed by Zed editor d/t dynamic binaries
        programs.nix-ld.enable = true;
      };
    };
}
