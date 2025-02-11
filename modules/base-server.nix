{lib, ...}: {
  imports = [
    ./base.nix
  ];

  documentation.nixos.enable = false;
  documentation.enable = false;
  documentation.info.enable = false;
  documentation.man.enable = false;

  environment.variables.BROWSER = "echo";

  time.timeZone = lib.mkDefault "UTC";
  systemd = {
    enableEmergencyMode = false;
    watchdog = {
      runtimeTime = "20s";
      rebootTime = "30s";
    };

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };
}
