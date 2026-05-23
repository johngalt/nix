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
        preservation
        docker

        # Service Modules
        scrutiny
        technitium
        komodo-periphery
        sanoid
        syncoid
        healthchecks
        zed
      ];

      config = {
        custom = {
          system = {
            preservation = {
              persistPath = "/persist";
              extraDirectories = [
                "/var/lib/private/technitium-dns-server"
                "/var/lib/komodo-periphery"
              ];
              extraFiles = [
                { file = "/etc/zfs/zpool.cache"; inInitrd = true; }
              ];
            };
          };
          services = {
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
              targetRoot = "tank/mirror/lithium";
              healthcheckId = "b3f07083-d532-4568-961d-51bb2bee7515";
            };
            zed = {
              toEmail = "a6bf278a-0962-4191-8c2a-20a18e512e0b@ping.nitron.app";
              fromEmail = "lithium@nitron.app";
              smtpServer = "argon.gudhak.home";
            };
          };
        };
      };
    };
}
