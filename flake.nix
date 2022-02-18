{
  outputs = { self, nixpkgs }: {
    nixosConfigurations.dell-xps-13-9310 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
}
