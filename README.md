My current home setup managed via Nix. 

## Libraries utilized:
- flake-parts: broke up configuration into a bunch of modules and profiles
- nix-wrapper-modules: wrapped up some packages that I previously had configured with hjem
- hjem: mainly used to create file linkers to home directory configs
- preservation: persist certain files/directories while using tmpfs for root file system

## Hosts:
- atlas (thinkpad x9 15, ultra 7 258v): personal laptop
- argon (i9-12900K): main media server that runs multiple docker containers managed via komodo
- cesium (dell optiplex, i5-10500T): running technitium dns and home automation stack
- lithium (dell optiplex, i5-10500T): running second clustered technitium dns instance
