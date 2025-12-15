{
  ...
}:
{
  imports = [
    ./docker.nix
    # ./home-manager - NOT USING ANYMORE IN FAVOR OF HJEM
    ./impermanence.nix
    ./hjem.nix
    ./nix.nix
    ./printing.nix
    ./sops.nix
    ./ssh.nix
    ./yubikey.nix
    ./zsh.nix
  ];
}
