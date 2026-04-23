{ ... }:
{
  flake.modules.nixos.git =
    { private, ... }:
    let
      name = private.fullname;
      email = private.email;
    in
    {
      programs.git = {
        enable = true;
        config = {
          init.defaultBranch = "main";
          pull.rebase = true;
          user = {
            inherit name email;
          };
        };
      };
    };
}
