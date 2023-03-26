{ config, pkgs, ... }:

let
  user = "thomas";
in
{
  home.username = user;
  home.homeDirectory = "/home/${user}";

  home.packages = with pkgs; [
    htop
    jq
    fd

    stow
  ];

  home.file."/home/${user}/.config/nvim/settings.lua".source = ./init.lua;

  # Need to set this outside home-manager
  # sudo chsh -s $(which zsh) $(whoami)
  home.file."/home/${user}/.bashrc".text = ''
    export SHELL=${pkgs.zsh}/bin/zsh
  '';

  home.file."/home/${user}/.config/alacritty/alacritty.yml".source = ./alacritty.yml;

  home.stateVersion = "22.11";

  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      # Themes
      gruvbox-material

      telescope-nvim
      nvim-comment
      gitsigns-nvim
      plenary-nvim

      luasnip
      nvim-cmp
      lualine-nvim
      fidget-nvim

      # LSP
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      null-ls-nvim
    ];

    extraPackages = with pkgs; [
      # Telescope
      fzf

      # Nix
      rnix-lsp
      nixfmt

      # Typescript
      nodePackages.prettier
      nodePackages.eslint
      nodePackages.typescript-language-server

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
    '';

    shellAliases = {
      g = "git";

      k = "kubectl";

      vim = "nvim";

      hme = "home-manager edit";
      hms = "home-manager switch && exec zsh";

      vimrc = "nvim ~/.config/home-manager/init.lua";
    };

    enableAutosuggestions = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "simple";

      plugins = [
        "aws"
        "docker"
        "git"
        "git-extras"
        "vi-mode"
        "yarn"
      ];
    };
  };

  programs.git = {
    enable = true;

    userName = "Thomas Crawford";
    userEmail = "ThomasJamesCrawford96@gmail.com";
  };

  programs.home-manager.enable = true;
}
