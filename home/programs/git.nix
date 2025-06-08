{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.unstable.git;
    delta = {
      enable = true;
      options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
    };
    userEmail = "btrghstk@gmail.com";
    userName = "botirk38";
    extraConfig = {
      credential.helper = "store";
    };
    extraConfig = {
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };
}
