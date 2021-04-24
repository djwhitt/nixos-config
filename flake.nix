{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    arweave = {
      url = "github:djwhitt/nix-arweave-bin/main";
    };
    desktopModules = {
      url = "/home/djwhitt/Work/nix-desktop-modules";
    };
  };

  outputs = { self, nixpkgs, arweave, desktopModules }:
    let 
      overlay = final: prev: {
        arweave-bin = arweave.defaultPackage.${prev.system};
      };
    in 
    {
      nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          #desktopModules.modules.test-module
          ./configuration.nix
	  { nixpkgs.overlays = [ overlay ]; }
        ];
      };
    };
}
