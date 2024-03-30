{
  description = ".dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { system = system; };

      font = pkgs.stdenv.mkDerivation {
        name = "hack-font";
        src = pkgs.fetchzip {
          url = "https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip";
          sha256 = "sha256-SxF4kYp9aL/9L9EUniquFadzWt/+PcvhUQOIOvCrFRM=";
        };
        installPhase = ''
          mkdir -p $out/share/fonts/truetype
          cp -r $src/* $out/share/fonts/truetype/
        '';
      };

      sqls-nvim = pkgs.vimUtils.buildVimPlugin {
        pname = "sqls.nvim";
        version = "v0.0.1";
        src = pkgs.fetchFromGitHub {
          owner = "nanotee";
          repo = "sqls.nvim";
          rev = "4b1274b5b44c48ce784aac23747192f5d9d26207";
          sha256 = "sha256-jKFut6NZAf/eIeIkY7/2EsjsIhvZQKCKAJzeQ6XSr0s=";
        };
        meta.homepage = "https://github.com/nanotee/sqls.nvim";
      };

    in
    {
      homeConfigurations = {
        thomas = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            {
              home.packages = [ font ];
            }

            {
              programs.neovim.plugins = [ sqls-nvim ];
            }

            ./home-manager/home.nix

          ];
        };
      };
    };
}

