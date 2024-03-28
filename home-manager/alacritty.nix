{ pkgs, ... }:

let
  mac = pkgs.system == "x86_64-darwin";
in
{
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
      dynamic_padding: true
      opacity: 0.8
  '';
}
