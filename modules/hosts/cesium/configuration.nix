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
        preservation
        docker

        # Service Modules
        scrutiny
        technitium
        renovate
        komodo-periphery
        sanoid
        syncoid
        healthchecks
        zed
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
              "zroot/containers"
              "zroot/persist"
            ];
            # Will replicate ZFS datasets and snapshots
            syncoid = {
              datasets = [
                "zroot/databases"
                "zroot/containers"
                "zroot/persist"
              ];
              targetRoot = "tank/mirror/cesium";
              healthcheckId = "4cf1a993-0ed2-430d-b17f-5e5cff33dedf";
            };
            zed = {
              toEmail = "53592fb1-3501-4d22-ab11-cb7ddc24ddff@ping.nitron.app";
              fromEmail = "cesium@nitron.app";
              smtpServer = "argon.gudhak.home";
            };
          };
        };
      };
    };
}
