{
  inputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../../secrets/default.yaml;
    validateSopsFiles = false;

    age = {
      sshKeyPaths = [
        "/persist/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key"
      ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  };
}
