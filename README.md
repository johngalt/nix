My current home setup managed via Nix. 

I was really bored so rewrote everything and changed the organization.

## Libraries utilized:
- flake-parts: broke up configuration into a bunch of modules and profiles
- nix-wrapper-modules: wrapped up some packages that I previously had configured with hjem
- hjem: mainly used to create file linkers to home directory configs

## Hosts:
- Argon: main media server that runs multiple docker containers managed via komodo
- Atlas: personal laptop
- DNS01: VM running Technitium DNS server for my home network
- Hydra: VM for running forgejo runner actions and renovate bot
- Incus: secondary server running Incus for managing VMs
