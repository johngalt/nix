{ ... }:
{
  flake.modules.nixos.hjem =
    { inputs, private, lib, ... }:
    let
      myUser = private.username;

      inherit (lib) mkAliasOptionModule;
    in
    {
      imports = [
        inputs.hjem.nixosModules.default

        # Create linker so `hj` option will refer to hjem user config options
        (mkAliasOptionModule [ "hj" ] [ "hjem" "users" myUser ])
      ];

      config = {
        hjem = {
          # Overwrite non-managed files by default
          clobberByDefault = true;
          users = {
            ${myUser} = {
              user = myUser;
              directory = "/home/${myUser}";
            };
          };
        };
      };
    };
}
