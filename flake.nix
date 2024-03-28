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

    in
    {
      homeConfigurations = {
        thomas = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            {
              home.packages = [ font ];
            }

            ./home-manager/home.nix
          ];
        };
      };
    };
}

