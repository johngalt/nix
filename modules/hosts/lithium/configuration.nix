{ self, ... }:
{
  flake.modules.nixos."hosts/lithium" =
    { ... }:
    {
      imports = with self.modules.nixos; [
        # Profiles
        base
        server

        # System Modules
        docker

        # Service Modules
        scrutiny
        technitium
        komodo-periphery
        sanoid
        syncoid
        healthchecks
      ];

      config = {
        custom = {
          services = {
            # Automated ZFS snapshots
            sanoid.datasets = [
              "zroot/databases"
              "zroot/docker"
              "zroot/home"
            ];
            # Will replicate ZFS datasets and snapshots
            syncoid = {
              datasets = [
                "zroot/databases"
                "zroot/docker"
                "zroot/home"
              ];
              targetRoot = "tank/mirror/lithium";
              healthcheckId = "b3f07083-d532-4568-961d-51bb2bee7515";
            };
          };
        };
      };
    };
}
