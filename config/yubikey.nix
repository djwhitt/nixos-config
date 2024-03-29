{ config, pkgs, ... }:

{
  services.pcscd.enable = true;

  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];

  environment.systemPackages = with pkgs; [
    libu2f-host
    yubikey-manager
    yubikey-manager-qt
    yubikey-personalization
    yubikey-personalization-gui
  ];

  # TODO: review whether this is needed
  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';

  # Work around pcscd suspend issues
  systemd.services.pcscd-suspend = {
    wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ]; 
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ]; 
    description = "Restart pcscd after resuming from suspend.";
    serviceConfig = {
      ExecStart = "/run/current-system/sw/bin/systemctl restart pcscd";
    };
  };
}
