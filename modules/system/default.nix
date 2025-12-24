{
  ...
}:
{
  imports = [
    ./docker.nix
    # ./home-manager - NOT USING ANYMORE IN FAVOR OF HJEM
    ./fish.nix
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
