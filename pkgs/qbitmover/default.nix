{
  pkgs,
  ...
}:
pkgs.writers.writePython3Bin "qbitmover" {
  libraries = [ pkgs.python3Packages.qbittorrent-api ];
  doCheck = false;
} (builtins.readFile ./qbitmover.py)
