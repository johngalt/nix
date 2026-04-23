{ lib }:

# Thanks llakala
# https://github.com/llakala/synaptic-standard/blob/main/demo/recursivelyImport.nix

let
  inherit (lib) hasSuffix hasPrefix;
  inherit (builtins) concatMap isPath filter readFileType;

  expandIfFolder = elem:
    if !isPath elem || readFileType elem != "directory"
      then [ elem ]
    else lib.filesystem.listFilesRecursive elem;

in
  list: filter
    # Filter out any path that doesn't look like `*.nix`. Don't forget to use
    # toString to prevent copying paths to the store unnecessarily
    # Slightly modified to ignore files with a "_" prefix
    (elem: !isPath elem || (hasSuffix ".nix" (toString elem) && !hasPrefix "_" (baseNameOf (toString elem))))
    # Expand any folder to all the files within it.
    (concatMap expandIfFolder list)
