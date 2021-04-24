{ config, pkgs, ... }:

{
  sound.enable = true;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    support32Bit = true; # for Steam
  };

  #services.jack = {
  #  jackd.enable = true;
  #  # support ALSA only programs via ALSA JACK PCM plugin
  #  alsa.enable = false;
  #  # support ALSA only programs via loopback device (supports programs like Steam)
  #  loopback = {
  #    enable = true;
  #  };
  #};

  #systemd.user.services.pulseaudio.environment = {
  #  JACK_PROMISCUOUS_SERVER = "jackaudio";
  #}; 
}
