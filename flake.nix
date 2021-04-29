{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    arweave = {
      url = "github:djwhitt/nix-arweave-bin/main";
    };
  };

  outputs = { self, nixpkgs, arweave }:
    let 
      overlay = final: prev: {
        arweave-bin = arweave.defaultPackage.${prev.system};
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
