# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let 
  #unstable = import <unstable> { config.allowUnfree = true; };
in
{
  #############################################################################
  ### Nix

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  nixpkgs.overlays = [
    (
      self: super: {
        falcon-sensor = super.callPackage ./overlays/falcon-sensor.nix { };
      }
    )
  ];

  #############################################################################
  ### Imports

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./config/locale.nix
      ./config/yubikey.nix
    ];

  #############################################################################
  ### Boot

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
  };

  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices.luksroot = { 
    device = "/dev/nvme0n1p2";
    preLVM = true;
    allowDiscards = true;
  };

  boot.kernelParams = [ "snd_hda_intel.dmic_detect=0" ];
  
  #############################################################################
  ### Hardware

  hardware = {
    enableAllFirmware = true;

    bluetooth.enable = true;
    ledger.enable = true;
    opengl = {
      driSupport32Bit = true;
      extraPackages = with pkgs; [ vaapiIntel libvdpau-va-gl vaapiVdpau ];
    };
  };

  #services.blueman.enable = true;
  services.udev.packages = [ pkgs.trezor-udev-rules ];
  custom.falcon.enable = true;

  #############################################################################
  ### Networking

  networking.hostName = "dell-xps-13-9310";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 3000 8081 8082 8280 8290 9630 ];
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.extraHosts =
    ''
      127.0.0.2 test.ario.localhost
      127.0.0.3 ardrive.ario.localhost
      127.0.0.4 jonniesparkles.ario.localhost
      127.0.0.5 guarding-the-gates_jonniesparkles.ario.localhost
      127.0.0.6 mmyp6ptokua7mkjqhxzuakamkhbivosxq2ced63ldfvz5mgcfana.ario.localhost
    '';

  services.openssh.enable = true;
  services.tailscale.enable = true;

  #############################################################################
  ### Sound

  sound.enable = true;

  # Enable RealtimeKit to reduce audio latency
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  #############################################################################
  ### Printing and Scanning

  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];
  };

  hardware.sane = {
    enable = true;
    brscan5.enable = true;
  };

  services.saned.enable = true;

  #############################################################################
  ### Virtualization

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
    };
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  xdg.portal = {
    enable = true;
  };

  #############################################################################
  ### Users

  security.sudo.wheelNeedsPassword = false;
  security.pam.services.slim.enableGnomeKeyring = true;

  users.extraUsers.djwhitt = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/djwhitt";
    shell = "/run/current-system/sw/bin/fish";
    extraGroups = [ "audio" "docker" "networkmanager" "video" "wheel" ];
  };

  #############################################################################
  ### Desktop
  
  #environment.variables = {
  #  QT_SCALE_FACTOR = "2";
  #  GDK_SCALE = "2";
  #  GDK_DPI_SCALE = "0.5";
  #  _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
  #};
  
  services.xserver = {
    enable = true;
    exportConfiguration = true;

    dpi = 235; 

    # Video
    videoDrivers = [ "modesetting" ];
    deviceSection = ''
      Option "DRI" "3"
    '';

    # Keyboard
    layout = "us";
    xkbOptions = "ctrl:nocaps";

    # Touchpad
    libinput = {
      enable = true;
      touchpad = {
      accelSpeed = "0.3";
        disableWhileTyping = true;
        tappingDragLock = false;
      };
    };

    displayManager = {
      defaultSession = "plasma";
      job.logToFile = true;
      lightdm = {
        enable = true;
        background = "#000000";
        greeters.gtk = {
          enable = true;
          cursorTheme = {
            name = "Vanilla-DMZ";
            package = pkgs.vanilla-dmz;
            size = 64;
          };
        };
      };
    };

    desktopManager = {
      xterm.enable = false;
      plasma5 = {
        enable = true;
      };
    };
  };

  services.gnome.gnome-keyring.enable = true;  

  #############################################################################
  ### Backups

  services.tarsnap = {
    enable = true;
    archives = {
      home = {
        directories = [
          "/home/djwhitt/.dotfiles"
          "/home/djwhitt/.dotfiles-private"
          "/home/djwhitt/.local/share/fish"
          "/home/djwhitt/Documents"
          "/home/djwhitt/Media/.git"
          "/home/djwhitt/Notes"
          "/home/djwhitt/Wiki"
        ];
        period = "*-*-* 00:00:00";
        excludes = [
          "/home/djwhitt/Media/.git/annex/objects"
        ];
      };

      nixos = {
        directories = [ "/etc/nixos" ];
        period = "*-*-* 02:00:00";
      };
    };
  };

  systemd.services.tarsnap-home-expire = {
    script = ''
      /run/current-system/sw/bin/tarsnapper \
        -o keyfile /root/tarsnap.key \
        -o cachedir /var/cache/tarsnap/root-tarsnap.key \
        --dateformat "%Y%m%d%H%M%S" \
        --target "home-\$date" \
        --deltas 1d 7d - expire
    '';
    # --deltas 1d 7d 30d 90d - expire
    wantedBy = [ "default.target" ];
  };

  systemd.timers.tarsnap-home-expire = {
    timerConfig = {
      Unit = "tarsnap-home-expire.service";
      OnCalendar = "*-*-* 04:00:00";
    };
    wantedBy = [ "default.target" ];
  };

  systemd.services.tarsnap-nixos-expire = {
    script = ''
      /run/current-system/sw/bin/tarsnapper \
        -o keyfile /root/tarsnap.key \
        -o cachedir /var/cache/tarsnap/root-tarsnap.key \
        --dateformat "%Y%m%d%H%M%S" \
        --target "nixos-\$date" \
        --deltas 1d 7d 30d 90d - expire
    '';
    wantedBy = [ "default.target" ];
  };

  systemd.timers.tarsnap-nixos-expire = {
    timerConfig = {
      Unit = "tarsnap-nixos-expire.service";
      OnCalendar = "*-*-* 04:00:00";
    };
    wantedBy = [ "default.target" ];
  };

  #############################################################################
  ### Databases

  #services.clickhouse.enable = true;

  #############################################################################
  ### Programs and Packages

  programs = {
    chromium.enable = true;
    gnome-terminal.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gnome3";
    };
    fish.enable = true;
    java.enable = true;
    mtr.enable = true;
    #seahorse.enable = true;
    slock.enable = true;
    ssh.startAgent = false;
    zsh.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    appimage-run
    blueman
    brightnessctl
    dejavu_fonts
    falcon-sensor
    font-awesome
    fzf
    git
    gnumake
    htop
    kitty
    libsForQt5.bismuth
    lsof
    mosh
    nfs-utils
    parted
    pciutils
    psmisc
    rcm
    tarsnap
    tarsnapper
    tmux
    tree
    unzip
    vim
    wget
    wine
    zoom-us
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

