{ config, pkgs, ... }:

{
  services.davmail = {
    enable = true;
    url = "https://mail.viasat.com/EWS/Exchange.asmx";
    config = {
      davmail.enableEws = "auto";
      davmail.ssl.nosecurecaldav = true;
      davmail.ssl.nosecureimap = true;
      davmail.ssl.nosecureldap = true;
      davmail.ssl.nosecurepop = true;
      davmail.ssl.nosecuresmtp = true;
      #log4j.logger.davmail = "DEBUG";
      #log4j.logger.httpclient.wire= "DEBUG";
      #log4j.logger.org.apache.commons.httpclient = "DEBUG";
      #log4j.rootLogger = "DEBUG";
    };
  };
}
