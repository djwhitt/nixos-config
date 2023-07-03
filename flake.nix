{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/release-23.05;
  inputs.nixos-hardware.url = github:NixOS/nixos-hardware/master;

  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations.dell-xps-13-9310 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-hardware.nixosModules.dell-xps-13-9310
        ./modules/falcon-sensor.nix
        ./configuration.nix
      ];
    };
  };
}
