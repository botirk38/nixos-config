{
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-index-database.hmModules.nix-index
    ./packages.nix
    ./variables.nix
    ./programs/shell.nix
    ./programs/git.nix
    ./programs/terminal.nix
    ./programs/development.nix
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
