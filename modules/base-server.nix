{lib, ...}: {
  imports = [
    ./base.nix
    ../system/services/docker.nix
  ];

  documentation.enable = false;
  documentation.nixos.enable = false;
  documentation.info.enable = false;
  documentation.man.enable = false;
  documentation.doc.enable = false;

  environment.variables.BROWSER = "echo";

  xdg = {
    autostart.enable = lib.mkDefault false;
    icons.enable = lib.mkDefault false;
    menus.enable = lib.mkDefault false;
    mime.enable = lib.mkDefault false;
    sounds.enable = lib.mkDefault false;
  };

  time.timeZone = lib.mkDefault "UTC";

  boot.initrd.systemd.suppressedUnits = [
    "emergency.service"
    "emergency.target"
  ];
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
