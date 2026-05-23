{ ... }:
{
  flake.modules.nixos._1password =
    { config, ... }:
    {
      programs._1password.enable = true;
      programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = [ config.hj.user ];
      };
    };
}
