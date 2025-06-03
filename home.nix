{
  pkgs,
  username,
  secrets,
  inputs,
  ...
}:

let
  unstable-packages = with pkgs.unstable; [
    bat
    bottom
    coreutils
    curl
    du-dust
    fd
    findutils
    fx
    git
    git-crypt
    htop
    jq
    killall
    mosh
    procs
    ripgrep
    sd
    tmux
    tree
    unzip
    vim
    wget
    zip
  ];

  stable-packages = with pkgs; [
    # CLI tools
    gh
    just
    cargo-cache
    cargo-expand
    mkcert
    httpie
    tree-sitter
    go
    gopls
    golangci-lint
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
    poetry
    gitui

    # Language + LSPs
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    nodePackages.pnpm
    nodePackages.eslint
    nodePackages.prettier
    ruff
    nil
    bun

    # Linters / formatters
    alejandra
    deadnix
    nodePackages.prettier
    shellcheck
    shfmt
    statix
    gcc
    (python3.withPackages (
      ps: with ps; [
        pip
        setuptools
        wheel
      ]
    ))
    nodejs_24
    neovim

    # Formatters and tools missing in conform.nvim / mason
    nixfmt-rfc-style
    sqlfluff
    luarocks
    lazygit
  ];
in
{
  imports = [ inputs.nix-index-database.hmModules.nix-index ];

  home.stateVersion = "25.05";

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    sessionVariables = {
      EDITOR = "nvim";
      SHELL = "/etc/profiles/per-user/${username}/bin/fish";
    };
  };

  home.packages = stable-packages ++ unstable-packages;

  programs = {
    home-manager.enable = true;

    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };

    nix-index-database.comma.enable = true;

    starship = {
      enable = true;
      settings = {
        aws.disabled = true;
        gcloud.disabled = true;
        kubernetes.disabled = false;
        git_branch.style = "242";
        directory = {
          style = "blue";
          truncate_to_repo = false;
          truncation_length = 8;
        };
        python.disabled = true;
        ruby.disabled = true;
        hostname = {
          ssh_only = false;
          style = "bold green";
        };
      };
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    lsd = {
      enable = true;
      enableFishIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = [ "--cmd cd" ];
    };

    broot = {
      enable = true;
      enableFishIntegration = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    git = {
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
      userName = "Botir Khaltaev";
      extraConfig = {
        url = {
          "https://oauth2:${secrets.github_token}@github.com" = {
            insteadOf = "https://github.com";
          };
          "https://oauth2:${secrets.gitlab_token}@gitlab.com" = {
            insteadOf = "https://gitlab.com";
          };
        };
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
      };
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        fish_add_path --append /mnt/c/Users/BotirKhaktaev/scoop/apps/win32yank/0.1.1
        ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

        ${pkgs.lib.strings.fileContents (
          pkgs.fetchFromGitHub {
            owner = "rebelot";
            repo = "kanagawa.nvim";
            rev = "de7fb5f5de25ab45ec6039e33c80aeecc891dd92";
            sha256 = "sha256-f/CUR0vhMJ1sZgztmVTPvmsAgp0kjFov843Mabdzvqo=";
          }
          + "/extras/kanagawa.fish"
        )}

        set -U fish_greeting
      '';
      functions = {
        refresh = "source $HOME/.config/fish/config.fish";
        take = ''mkdir -p -- "$1" && cd -- "$1"'';
        ttake = "cd (mktemp -d)";
        show_path = ''
          echo $PATH | tr ' ' '
        '';
        posix-source = ''
          for file in $argv
            for line in (cat $file)
              set arr (string split "=" $line)
              set -gx $arr[1] $arr[2]
            end
          end
        '';
      };
      shellAbbrs = {
        gc = "nix-collect-garbage --delete-old";
        ".." = "cd ..";
        "..." = "cd ../../";
        "...." = "cd ../../../";
        "....." = "cd ../../../../";
        gapa = "git add --patch";
        grpa = "git reset --patch";
        gst = "git status";
        gdh = "git diff HEAD";
        gp = "git push";
        gph = "git push -u origin HEAD";
        gco = "git checkout";
        gcob = "git checkout -b";
        gcm = "git checkout master";
        gcd = "git checkout develop";
        gsp = "git stash push -m";
        gsa = "git stash apply stash^{/";
        gsl = "git stash list";
      };
      shellAliases = {
        vim = "nvim";
        pbcopy = "/mnt/c/Windows/System32/clip.exe";
        pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
        explorer = "/mnt/c/Windows/explorer.exe";
      };
      plugins = [
        {
          inherit (pkgs.fishPlugins.autopair) src;
          name = "autopair";
        }
        {
          inherit (pkgs.fishPlugins.done) src;
          name = "done";
        }
        {
          inherit (pkgs.fishPlugins.sponge) src;
          name = "sponge";
        }
      ];
    };
  };
}
