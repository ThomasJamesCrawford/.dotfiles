{ config, pkgs, ... }:

let
  username =
    if pkgs.system == "x86_64-darwin"
    then "thomascrawford"
    else "thomas";

  homeDirectory =
    if pkgs.system == "x86_64-darwin"
    then "/Users/${username}"
    else "/home/${username}";

in
{
  home.username = username;
  home.homeDirectory = homeDirectory;

  home.packages = with pkgs; [
    htop
    jq
    fd

    stow
  ];

  home.file.".config/nvim/settings.lua".source = ./init.lua;

  # Need to set this outside home-manager
  # sudo chsh -s $(which zsh) $(whoami)
  home.file.".bashrc ".text = ''
    export SHELL=${pkgs.zsh}/bin/zsh
  '';

  home.file.".config/alacritty/alacritty.yml".source = ./alacritty.yml;

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
    '';

    shellAliases = {
      g = "git";

      k = "kubectl";

      atpj = "cd $HOME/ailo/atp-jellyfish-v2";
      atpc = "cd $HOME/ailo/atp-cluster";

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
        # "aws"
        "docker"
        "git"
        "git-extras"
        "vi-mode"
        "yarn"
      ];
    };
  };

  # programs.git = {
  #   enable = true;
  #
  #   userName = "Thomas Crawford";
  #   userEmail = "ThomasJamesCrawford96@gmail.com";
  # };

  programs.home-manager.enable = true;
}



