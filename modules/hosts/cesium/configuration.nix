{ self, ... }:
{
  flake.modules.nixos."hosts/cesium" =
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
        renovate
        komodo-periphery
        sanoid
        syncoid
        healthchecks
      ];

      config = {
        custom = {
          services = {
            beszel.extraEnv = {
              SENSORS = "-dell_smm_18"; # broken temp sensor
            };
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
              targetRoot = "tank/mirror/cesium";
              healthcheckId = "4cf1a993-0ed2-430d-b17f-5e5cff33dedf";
            };
          };
        };
      };
    };
}
