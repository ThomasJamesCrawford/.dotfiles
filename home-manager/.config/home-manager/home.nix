{ config, pkgs, ... }:

let
  mac = pkgs.system == "x86_64-darwin";

  username =
    if mac
    then "thomascrawford"
    else "thomas";

  homeDirectory =
    if mac
    then "/Users/${username}"
    else "/home/${username}";

  font = with pkgs; import ./font.nix {
    inherit stdenv fetchzip;
  };
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    htop
    jq
    fd
    gh

    stow

    font
  ];

  home.file.".config/nvim/settings.lua".source = ./init.lua;

  # Need to set this outside home-manager
  # sudo chsh -s $(which zsh) $(whoami)
  home.file.".bashrc".text = ''
    export SHELL=${pkgs.zsh}/bin/zsh
  '';

  home.file.".config/alacritty/alacritty.yml".text = ''
    # Colors (Gruvbox Material Dark Medium)
    colors:
      bright:
        black: "0x928374"
        blue: "0x7daea3"
        cyan: "0x89b482"
        green: "0xa9b665"
        magenta: "0xd3869b"
        red: "0xea6962"
        white: "0xdfbf8e"
        yellow: "0xe3a84e"

      normal:
        black: "0x665c54"
        blue: "0x7daea3"
        cyan: "0x89b482"
        green: "0xa9b665"
        magenta: "0xd3869b"
        red: "0xea6962"
        white: "0xdfbf8e"
        yellow: "0xe78a4e"

      primary:
        background: "0x282828"
        foreground: "0xdfbf8e"

    env:
      TERM: xterm-256color

    font:
      normal:
        family: ${if mac then "MesloLGS NF" else "Hack"}
        style: Regular

      size: ${if mac then "16" else "13"}

    shell:
      program: .nix-profile/bin/zsh
      args:
        - -l
        - -c
        - .nix-profile/bin/tmux

    window:
      ${if !mac then "decorations: none" else ""}
      dynamic_padding: true
      opacity: 0.8
      # padding:
      #   x: 12
      #   y: 12
      ${if !mac then "startup_mode: Maximized" else ""}
  '';

  home.stateVersion = "22.11";

  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      # Themes
      gruvbox-material

      telescope-nvim
      nvim-comment
      plenary-nvim

      gitsigns-nvim
      lualine-nvim
      fidget-nvim

      # LSP
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      null-ls-nvim
      nvim-cmp
      luasnip
    ];

    extraPackages = with pkgs; [
      # Telescope
      fzf

      # Nix
      rnix-lsp
      nixfmt

      # Typescript
      nodePackages.prettier_d_slim
      nodePackages.eslint_d
      nodePackages.typescript-language-server
      # nodePackages.vscode-eslint-language-server

      # Lua
      lua-language-server
      stylua

      # Rust
      rust-analyzer

      # YAML
      yaml-language-server

      # Go
      go
      gopls
      golangci-lint
      golangci-lint-langserver

      # Shell
      shfmt
      shellcheck
      nodePackages.bash-language-server
    ];

    extraConfig = ''
      luafile ~/.config/nvim/settings.lua
    '';
  };

  programs.zsh = {
    enable = true;

    initExtra = ''
      export EDITOR=nvim

      # This fixes gpg signing
      export GPG_TTY=$TTY

      source ~/.secrets/secrets.sh

      export TERM=xterm-256color

      export LC_ALL="en_US.UTF-8"

      export SHELL=${pkgs.zsh}/bin/zsh
    '';

    shellAliases = {
      g = "git";

      k = "kubectl";

      atpj = "cd $HOME/ailo/atp-jellyfish-v2";
      atpc = "cd $HOME/ailo/atp-cluster";

      gho = "cd $HOME";
      ga = "cd $HOME/ailo";
      gr = "cd $HOME/repos";

      vim = "nvim";

      hme = "home-manager edit";
      hms = "home-manager switch && exec zsh";
      gdf = "cd ~/.dotfiles";

      vimrc = "nvim ~/.config/home-manager/init.lua";
    };

    enableAutosuggestions = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "simple";

      plugins = [
        # "aws"
        "docker"
        "git"
        "git-extras"
        "vi-mode"
        "yarn"
      ];
    };
  };

  programs.tmux = {
    enable = true;

    keyMode = "vi";
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      yank
      {
        plugin = power-theme;
        extraConfig = ''
          set -g @tmux_power_theme '#7daea3'
        '';
      }
    ];

    extraConfig = ''
      # TERM override
      set terminal-overrides "xterm*:RGB"

      # Enable mouse
      set -g mouse on

      # Pane movement shortcuts (same as vim)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind-key v split-window -h
      bind-key s split-window -v

      bind Enter copy-mode

      # Start selection with 'v' and copy using 'y'
      bind-key -T copy-mode-vi v send-keys -X begin-selection
    '';
  };

  # programs.git = {
  #   enable = true;
  #
  #   userName = "Thomas Crawford";
  #   userEmail = "ThomasJamesCrawford96@gmail.com";
  # };

  programs.home-manager.enable = true;
}
