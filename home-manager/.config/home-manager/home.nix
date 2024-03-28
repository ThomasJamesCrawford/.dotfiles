{ pkgs, lib, ... }:

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

  fromGitHub = ref: repo: pkgs.vimUtils.buildVimPlugin {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      ref = ref;
    };
  };
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;

  fonts.fontconfig.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.packages = (with pkgs; [
    htop
    jq
    bash
    zsh
    tmux

    diff-so-fancy

    fd
    ripgrep
    go

    awscli2
    kubectl
    k9s
    k6
    aws-vault

    gh

    stow

    font
  ]) ++ (if mac then [
    (builtins.getFlake "git+ssh://git@github.com/ailohq/ailo-tools.git")
  ] else [ ]);

  home.file.".config/nvim/settings.lua".source = ./init.lua;

  # Need to set this outside home-manager
  # sudo chsh -s $(which zsh) $(whoami)
  #home.file.".bashrc".text = ''
  #  # export SHELL=${pkgs.zsh}/bin/zsh
  #'';

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
      program: ${pkgs.zsh}/bin/zsh
      args:
        - -l
        - -c
        - ${pkgs.tmux}/bin/tmux

    ${if !mac then "background_opacity: 0.8" else ""}
    window:
      ${if !mac then "decorations: none" else ""}
      dynamic_padding: true
      opacity: 0.8
      # padding:
      #   x: 12
      #   y: 12
      ${if !mac then "startup_mode: Maximized" else ""}
  '';

  home.stateVersion = "24.05";

  programs.direnv.enable = true;

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
      none-ls-nvim
      nvim-cmp
      luasnip
      cmp-nvim-lsp
      cmp_luasnip

      # Mine
      (fromGitHub "refs/tags/v0.0.3" "ThomasJamesCrawford/openai.nvim")

      copilot-lua

    ];

    extraPackages = with pkgs; [
      # Telescope
      fzf

      # Nix
      nixpkgs-fmt
      nil

      # Typescript
      nodePackages.prettier_d_slim
      nodePackages.prettier
      nodePackages.eslint_d
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

      path+=('/Users/thomascrawford/.docker/bin')

      export PATH
    '';

    shellAliases = {
      g = "git";

      k = "kubectl";

      atpj = "cd $HOME/ailo/atp-jellyfish-v2";
      atpc = "cd $HOME/ailo/atp-cluster";
      chap = "eval \"$(ailo-tools shell_change_profile)\"";

      ailo-tools = "nix run git+ssh://git@github.com/ailohq/ailo-tools.git --tarball-ttl 68400";

      gho = "cd $HOME";
      ga = "cd $HOME/ailo";
      gr = "cd $HOME/repos";

      vim = "nvim";

      ghpr = "gh pr create --fill";
      ghprv = "gh pr --view";

      hme = "home-manager edit";
      hms = "home-manager switch && exec zsh";
      gdf = "cd ~/.dotfiles";

      vimrc = "nvim ~/.config/home-manager/init.lua";

      sail = "[ -f sail ] && sh sail || sh vendor/bin/sail";
    };

    autosuggestion.enable = true;
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

    package = pkgs.tmux;

    keyMode = "vi";
    terminal = "xterm-256color";

    #plugins = with pkgs.tmuxPlugins; [
    #  yank
    #  {
    #    plugin = power-theme;
    #    extraConfig = ''
    #      set -g @tmux_power_theme '#7daea3'
    #    '';
    #  }
    #];

    extraConfig = ''
      # 0 is far away
      set -g base-index 1
      setw -g pane-base-index 1

      # Enable mouse
      set -g mouse on

      # Pane movement shortcuts (same as vim)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind-key v split-window -h -c "#{pane_current_path}"
      bind-key s split-window -v -c "#{pane_current_path}"

      bind Enter copy-mode

      # Start selection with 'v' and copy using 'y'
      bind-key -T copy-mode-vi v send-keys -X begin-selection

      ## COLORSCHEME: gruvbox dark (medium)
      set-option -g status "on"

      # default statusbar color
      set-option -g status-style bg=colour237,fg=colour223 # bg=bg1, fg=fg1

      # default window title colors
      set-window-option -g window-status-style bg=colour214,fg=colour237 # bg=yellow, fg=bg1

      # default window with an activity alert
      set-window-option -g window-status-activity-style bg=colour237,fg=colour248 # bg=bg1, fg=fg3

      # active window title colors
      set-window-option -g window-status-current-style bg=red,fg=colour237 # fg=bg1

      # pane border
      set-option -g pane-active-border-style fg=colour250 #fg2
      set-option -g pane-border-style fg=colour237 #bg1

      # message infos
      set-option -g message-style bg=colour239,fg=colour223 # bg=bg2, fg=fg1

      # writing commands inactive
      set-option -g message-command-style bg=colour239,fg=colour223 # bg=fg3, fg=bg1

      # pane number display
      set-option -g display-panes-active-colour colour250 #fg2
      set-option -g display-panes-colour colour237 #bg1

      # clock
      set-window-option -g clock-mode-colour colour109 #blue

      # bell
      set-window-option -g window-status-bell-style bg=colour167,fg=colour235 # bg=red, fg=bg

      ## Theme settings mixed with colors (unfortunately, but there is no cleaner way)
      set-option -g status-justify "left"
      set-option -g status-left-style none
      set-option -g status-left-length "80"
      set-option -g status-right-style none
      set-option -g status-right-length "80"
      set-window-option -g window-status-separator ""

      set-option -g status-left "#[bg=colour241,fg=colour248] #S #[bg=colour237,fg=colour241,nobold,noitalics,nounderscore]"
      set-option -g status-right "#[bg=colour237,fg=colour239 nobold, nounderscore, noitalics]#[bg=colour239,fg=colour246] %Y-%m-%d  %H:%M #[bg=colour239,fg=colour248,nobold,noitalics,nounderscore]#[bg=colour248,fg=colour237] #h "

      set-window-option -g window-status-current-format "#[bg=colour214,fg=colour237,nobold,noitalics,nounderscore]#[bg=colour214,fg=colour239] #I #[bg=colour214,fg=colour239,bold] #W#{?window_zoomed_flag,*Z,} #[bg=colour237,fg=colour214,nobold,noitalics,nounderscore]"
      set-window-option -g window-status-format "#[bg=colour239,fg=colour237,noitalics]#[bg=colour239,fg=colour223] #I #[bg=colour239,fg=colour223] #W #[bg=colour237,fg=colour239,noitalics]"

      # vim: set ft=tmux tw=0 nowrap:
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
