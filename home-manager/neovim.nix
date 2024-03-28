{ pkgs, ... }:

{
  home.file.".config/nvim/settings.lua".source = ./init.lua;

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

      ## LSP
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      none-ls-nvim
      nvim-cmp
      #luasnip
      cmp-nvim-lsp
      cmp_luasnip

      copilot-lua
    ];

    extraPackages = with pkgs; [
      # Telescope
      fzf

      # Nix
      nixpkgs-fmt
      nil

      # Typescript
      nodePackages.typescript-language-server
      biome

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
}
