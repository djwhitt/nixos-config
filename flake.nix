{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/release-21.11;
  inputs.nixos-hardware.url = github:NixOS/nixos-hardware/master;

  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations.dell-xps-13-9310 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-hardware.nixosModules.dell-xps-13-9310
        ./configuration.nix
      ];
    };
  };
}
