{
  pkgs,
  ...
}:
pkgs.writers.writePython3Bin "davocache" {
  libraries = [ pkgs.python312Packages.requests ];
  doCheck = false;
} (builtins.readFile ./davocache.py)
