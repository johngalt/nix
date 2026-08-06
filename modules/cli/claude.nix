{ inputs, ... }:
{
  flake.modules.nixos.claude =
    { pkgs, ... }:
    {
      environment.systemPackages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        claude-code
      ];
    };
}
