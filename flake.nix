{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    arweave.url = "github:djwhitt/nix-arweave-bin/main";
    babashka-static-bin.url = "github:djwhitt/nix-babahska-static-bin-pkg";
  };

  outputs = { self, nixpkgs, arweave, babashka-static-bin }:
    let 
      overlay = final: prev: {
        arweave-bin = arweave.defaultPackage.${prev.system};
        babashka-static-bin = babashka-static-bin.defaultPackage.${prev.system};
      };
    in 
    {
      nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./configuration.nix
	  { nixpkgs.overlays = [ overlay ]; }
        ];
      };
    };
}
