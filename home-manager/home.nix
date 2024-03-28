{ pkgs, ... }:
{
  imports = [
    ./alacritty.nix
    ./neovim.nix
    ./tmux.nix
  ];

  home.username = "thomas";
  home.homeDirectory = "/home/thomas";
  home.stateVersion = "23.05";

  fonts.fontconfig.enable = true;

  home.packages = (with pkgs; [
    htop
    jq
    bash
    zsh
    tmux

    diff-so-fancy

    fd
    ripgrep
    fzf
    go

    awscli2
    kubectl
    k9s
    aws-vault

    gh

    pure-prompt
  ]);

  programs.direnv.enable = true;

  programs.zsh = {
    enable = true;

    initExtra = ''
      export EDITOR=nvim

      # This fixes gpg signing
      export GPG_TTY=$TTY

      source ~/.secrets/secrets.sh

      export TERM=xterm-256color

      export LC_ALL="en_US.UTF-8"

      autoload -U promptinit; promptinit
      prompt pure
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
      hms = "nix run nixpkgs#home-manager -- switch --flake \"$HOME/.dotfiles#$USER\" && exec zsh";
      gdf = "cd ~/.dotfiles";

      vimrc = "nvim ~/$HOME/.dotfiles/home-manager/init.lua";
    };

    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    plugins = with pkgs; [{
      name = "pure";
      src = pure-prompt;
    }];

    oh-my-zsh = {
      enable = true;
      theme = "";

      plugins = [
        "fzf"
        "kubectl"
        "git"
        "ripgrep"
        "golang"
        "helm"
      ];
    };
  };

  programs.home-manager.enable = true;
}
