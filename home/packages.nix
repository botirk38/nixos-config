{ pkgs, ... }:
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
    git-credential-manager
    sops
    gnupg
    pinentry-curses
    prisma-engines
    prisma
    openssl

    # Language + LSPs
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    nodePackages.pnpm
    nodePackages.eslint
    nodePackages.prettier
    ruff
    nil
    bun
    opencommit
    biome
    lua-language-server

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
  home.packages = stable-packages ++ unstable-packages;
}
