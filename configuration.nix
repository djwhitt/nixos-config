# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let 
  #unstable = import <unstable> { config.allowUnfree = true; };

  alohomora = import ./pkgs/alohomora.nix pkgs;
  babashka-bin = import ./pkgs/babashka-bin.nix pkgs;
  clj-kondo-bin = import ./pkgs/clj-kondo-bin.nix pkgs;
in
{
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./config/locale.nix
      ./config/networking.nix
      ./config/sound.nix
      ./config/yubikey.nix
    ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
    #boot.loader.grub.extraConfig = ''
    #  set check_signatures=no
    #'';
  };

  boot.initrd.luks.devices = { "cryptroot" = { device = "/dev/sda2"; preLVM = true; }; };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.config = {
    allowUnfree = true;
  };

  hardware = {
    bluetooth = {
      enable = true;
    };

    enableAllFirmware = true;

    opengl = {
      driSupport32Bit = true;
      extraPackages = with pkgs; [ vaapiIntel libvdpau-va-gl vaapiVdpau intel-ocl ];
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
    };
  };

  services.blueman.enable = true;
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  services.gnome3.gnome-keyring.enable = true;  
  #services.gnome3.gnome-settings-daemon.enable = true;

  #############################################################################
  ### Networking

  networking.hostName = "thinkpad";
  networking.networkmanager.enable = true;

  #############################################################################
  ### Users

  security.sudo.wheelNeedsPassword = false;
  security.pam.services.slim.enableGnomeKeyring = true;

  users.extraUsers.djwhitt = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/djwhitt";
    shell = "/run/current-system/sw/bin/fish";
    extraGroups = [ "audio" "docker" "jackaudio" "networkmanager" "wheel" ];
  };

  #############################################################################
  ### Programs and Packages

  programs = {
    chromium.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    java.enable = true;
    mtr.enable = true;
    seahorse.enable = true;
    ssh.startAgent = false;
    zsh.enable = true;
    fish.enable = true;
  };

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };
  
  services.lorri.enable = true;

  #############################################################################
  ### X
  
  services.redshift = {
    enable = true;
    temperature.day = 6200;
    temperature.night = 3700;
  };

  #services.clight = {
  #  enable = true;
  #  settings = {
  #    #ac_regression_points = [ 0.0 0.15 0.29 0.45 0.61 0.74 0.81 0.88 0.93 0.97 1.0 ];
  #    ac_regression_points = [ 0.8 0.8 0.8 0.8 0.8 0.8 0.9 0.9 0.93 0.97 1.0 ];
  #  };
  #};

  services.xserver = {
    enable = true;
    exportConfiguration = true;

    # Video
    #videoDrivers = [ "modesetting" ];
    #useGlamor = true;

    videoDrivers = [ "intel" ];
    deviceSection = ''
      Option "DRI" "2"
      Option "TearFree" "true"
    '';

    # Keyboard
    layout = "us";
    xkbOptions = "ctrl:nocaps";

    displayManager = {
      defaultSession = "xfce+i3";
      lightdm.enable = true;
      job.logToFile = true;
    };

    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };

    libinput = {
      enable = true;
      accelSpeed = "0.3";
      disableWhileTyping = true;
      tappingDragLock = false;
    };

    windowManager.i3.enable = true;
  };

  #services.picom = {
  #  enable = true;
  #  backend = "glx";
  #  vSync = true;
  #};

  services.syncthing = {
    enable = true;
    user = "djwhitt";
    group = "users";
    dataDir = "/home/djwhitt";
    configDir = "/home/djwhitt/.config/syncthing";   
    openDefaultPorts = true;
  };

  #############################################################################
  ### WireGuard

  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.firewall.trustedInterfaces = [ "wg0" ];

  networking.nat = {
    enable = true;
    externalInterface = "eth0";
    internalInterfaces = [ "wg0" ];
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "192.168.8.3/22" ];

    # TODO: find a better location for private key
    privateKeyFile = "/root/wireguard-keys/private";

    peers = [
      {
        publicKey = "E5VNx3Qq0r9bZxYDM1A2TSaMV9Z2vZU6NMEwI/8r7Ec=";
        allowedIPs = [ "192.168.8.0/22" ];
        endpoint = "192.168.5.12:51820";
        #endpoint = "vpn.spcom.org:51820";
        persistentKeepalive = 25;
      }
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alohomora
    anki
    aumix
    awscli
    babashka-bin
    blueman
    #bluez-alsa
    brightnessctl
    chromium
    clj-kondo-bin
    clojure
    copyq
    dejavu_fonts
    direnv
    ditaa
    drawio
    evince
    firefox
    fish
    flameshot
    freecad
    gcc
    git
    git-lfs
    gitAndTools.git-subrepo
    gnome3.gnome-terminal
    gnome3.seahorse
    gnumake
    graphviz
    htop
    #hugo
    inetutils
    kitty
    lastpass-cli
    leafpad
    leiningen
    libreoffice
    lorri
    lsof
    mosh
    mr
    mu
    nodejs
    offlineimap
    openjdk11
    pamix
    pamixer
    pinentry-gtk2
    plantuml
    psmisc
    python
    python38Packages.html2text
    qjackctl
    rcm
    ripgrep
    silver-searcher
    sqlite
    steam
    syncthing
    texlive.combined.scheme-full
    tmux
    tree
    unzip
    vim
    wget
    wmctrl
    xdotool
    xorg.xev
    xpad
    arweave-bin
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  services.nginx = {
    enable = true;

    virtualHosts."crux-dev" = {
      locations."/" = {
        proxyPass = "http://192.168.8.1:5000";
	extraConfig = ''
          if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
            
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
            
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
          }
	  if ($request_method = 'POST') {
	    add_header 'Access-Control-Allow-Origin' '*' always;
	    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
	    add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
	    add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
	  }
	  if ($request_method = 'GET') {
	    add_header 'Access-Control-Allow-Origin' '*' always;
	    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
	    add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
	    add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
	  }
        '';
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}

