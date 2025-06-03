# nixos-config

This repository contains my personal NixOS configuration, built upon the
[LGUG2Z/nixos-wsl-starter](https://github.com/LGUG2Z/nixos-wsl-starter) template,
adapted for my needs to run a LazyVim powered
NixOS development environment on WSL.

If you don't want to dig into NixOS too much right now, the only file you need
to concern yourself with is [home.nix](home.nix). This is where you can add and
remove binaries to your global `$PATH`.

Go to [https://search.nixos.org](https://search.nixos.org/packages) to find the
correct package names; usually, they will be what you expect them to be
in other package managers.

`unstable-packages` is for packages that you want to always keep at the latest
released versions, and `stable-packages` is for packages that you want to track
with the current release of NixOS (currently 25.05).

If you want to update the versions of the available `unstable-packages`, run
`nix flake update` to pull the latest version of the Nixpkgs repository and
then apply the changes with `sudo nixos-rebuild switch`.

Make sure to look at all the `FIXME` notices in the various files, which are
intended to direct you to places where you may want to make configuration
tweaks.

## What Is Included

This configuration is a lightly-opinionated take on a productive terminal-driven
development environment based on my own preferences. However, it is trivial to
customize to your liking both by removing and adding tools that you prefer.

- The default editor is [JeezyVim](https://github.com/LGUG2Z/JeezyVim)
- `win32yank` is used to ensure perfect bi-directional copying and pasting to
  and from Windows GUI applications and LunarVim running in WSL
- The default shell is `fish`
- Native `docker` (ie. Linux, not Windows) is enabled by default
- The prompt is [Starship](https://starship.rs/)
- [`fzf`](https://github.com/junegunn/fzf),
  [`lsd`](https://github.com/lsd-rs/lsd),
  [`zoxide`](https://github.com/ajeetdsouza/zoxide), and
  [`broot`](https://github.com/Canop/broot) are integrated into `fish` by
  default
  - These can all be disabled easily by setting `enable = false` in
    [home.nix](home.nix), or just removing the lines all together
- [`direnv`](https://github.com/direnv/direnv) is integrated into `fish` by
  default
- `git` config is generated in [home.nix](home.nix) with options provided to
  enable private HTTPS clones with secret tokens
- `fish` config is generated in [home.nix](home.nix) and includes git aliases,
  useful WSL aliases

### win32yank

There have been some recent changes in WSL2 that make running `win32yank`
within WSL2 very slow. You should install this on Windows by running `scoop
install win32yank` or compiling it from source, and then adding it to your `$PATH`:

```nix
{
    programs.fish = {
      interactiveShellInit = ''
        fish_add_path --append /mnt/c/Users/<Your Windows Username>/scoop/apps/win32yank/0.1.1
      '';
    };
}
```

## Quickstart

[![Watch the walkthrough video](https://img.youtube.com/vi/ZuVQds2hncs/hqdefault.jpg)](https://www.youtube.com/watch?v=ZuVQds2hncs)
_(Note: The video refers to the original template; some steps below may differ slightly)_

- Get the [latest
  release](https://github.com/LGUG2Z/nixos-wsl-starter/releases) of the **base template** (or a fresh `nixos-wsl.tar.gz` from NixOS-WSL releases directly).
- Install it (tweak the command to your desired paths and distro name):

```powershell
wsl --import NixOS .\NixOS\ .\nixos-wsl.tar.gz --version 2
```

- Enter the distro:

```powershell
wsl -d NixOS
```

- Get a copy of _this_ repository into a temporary location:

```bash
git clone https://github.com/botirk38/nixos-config.git /tmp/configuration
cd /tmp/configuration
```

- **Important:** Ensure your desired username (`botirk`) is correctly set in `flake.nix` within the `mkNixosConfiguration` block. If you changed it after the initial import, you'll need to rebuild.
- Install `win32yank` on Windows with `scoop` and add its path to your NixOS configuration (see example above).
- Apply the configuration and shutdown the WSL2 VM:

```bash
sudo nixos-rebuild switch --flake /tmp/configuration && sudo shutdown -h now
```

- Reconnect to the WSL2 VM:

```bash
wsl -d NixOS
```

- `cd ~` and then `pwd` should now show `/home/<YOUR_USERNAME>` (e.g., `/home/botirk`)
- Move the configuration to your new home directory:

```bash
mv /tmp/configuration ~/configuration
```

- Go through all the `FIXME:` notices in `~/configuration` and make changes
  wherever you want.
- Apply the configuration (and any subsequent updates):

```bash
sudo nixos-rebuild switch --flake ~/configuration
```

Note: If developing in Rust, you'll still be managing your toolchains and
components like `rust-analyzer` with `rustup`!

## Project Layout

In order to keep the template as approachable as possible for new NixOS users,
this project uses a flat layout without any nesting or modularization.

- `flake.nix` is where dependencies are specified and NixOS configurations are defined.
  - `nixpkgs` is the current release of NixOS.
  - `nixpkgs-unstable` is the current trunk branch of NixOS (ie. all the
    latest packages).
  - `home-manager` is used to manage everything related to your home
    directory (dotfiles etc.), integrated directly into the NixOS system build.
  - `nur` is the community-maintained [Nix User
    Repositories](https://nur.nix-community.org/) for packages that may not
    be available in the NixOS repository.
  - `nixos-wsl` exposes important WSL-specific configuration options.
  - `nix-index-database` tells you how to install a package when you run a
    command which requires a binary not in the `$PATH`.
- `wsl.nix` is where the VM is configured.
  - The hostname is set here.
  - The default shell is set here.
  - User groups are set here.
  - WSL configuration options
