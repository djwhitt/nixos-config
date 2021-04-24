{ config, pkgs, ... }:

{
  # Madison, WI
  location.latitude = 43.0731;
  location.longitude = -89.4012;

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "US/Central";
}
