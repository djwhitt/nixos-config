{ config, pkgs, ... }:

{
  networking = {
    hosts = {
      "192.168.8.1" = [ "home-server" ];
      "192.168.8.2" = [ "lp-dwhittin-linux" ];
      "192.168.8.3" = [ "thinkpad" ];
      "127.0.0.1" = [ "crux-dev" ];
    };
  };

  services.openssh.enable = true;
}
