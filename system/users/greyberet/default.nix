{
  pkgs,
  config,
  inputs,
  ...
}: {
  sops.secrets.greyberet_pass.neededForUsers = true;

  users.users.greyberet = {
    isNormalUser = true;
    extraGroups = [];
    shell = pkgs.bash;

    hashedPasswordFile = config.sops.secrets.greyberet_pass.path;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDN8xvkZaXb1MkS04drQe+ncKoTrquupDKHlBqiQTUoWu5uqINh+SgEIgsmTsrCZPBahnxxcFvj8RM7f7ndBew5lwsEJ3uX1P2s2iRHkw12cRiajXSmqi1JR5lZv3CwT5KwQg9lTyDBhLINuBdysLEdOa/wYmH07Wz1y6uQh+LEHjYqqhdW8wxL7pV/5cG8jNF5E3y99nnIOFXvbtTm6IQHwOLj/VJzfjao/p8thUaZQyhUAQuZXVZnK3eCSqwE7TRv4MILQw0ntjRutUQsBXPoJskaDZY5eZzmGQyNbEoF99BtGVVP/EL7Da1cDhzkl3UvFj1g8TTJEipi8O2CEB2SqLlQPvINl25+lQ1zGxaUCF6YUvprsrVdjRetRLZy6hrhD66lDlYXOhZCensifUpXp/OEt79biHYFA1VnFJknwOWMPIMiwVfM2pG2cSbIOmBX8ApO01m8vOLdgvWtTqH+NyMzGppO/WmhZcgD1JP+CZBuBjc/4Hyd6Cka4mbqxos= win@DESKTOP-73F9F12"
    ];
    packages = [pkgs.openjdk21 pkgs.wget pkgs.curl pkgs.tmux pkgs.packwiz pkgs.git pkgs.rclone inputs.mc_tools.packages.${pkgs.system}.default];
  };

  # Enable user services for greyberet
  systemd.user.services.minecraft-backup = {
    description = "Minecraft Server Backup Service";
    enable = true;
    script = ''
      /home/greyberet/backup.sh backup --world-dir /home/greyberet/creative/world_creative --backup-dir /home/greyberet/backups/creative --server-session creative
      /home/greyberet/backup.sh backup --world-dir /home/greyberet/lobby/world --backup-dir /home/greyberet/backups/lobby --server-session loobby
      /home/greyberet/backup.sh backup --world-dir /home/greyberet/survival/world --backup-dir /home/greyberet/backups/survival --server-session survival
    '';
    serviceConfig = {
      User = "greyberet";
      Group = "users";
      Restart = "on-failure";
      TimeoutStartSec = 600;
      TimeoutStopSec = 600;
    };
    unitConfig.ConditionUser = "greyberet";
    path = [pkgs.tmux];
    wantedBy = ["default.target"];
  };

  # Create and enable the timer for backups
  systemd.user.timers.minecraft-backup = {
    description = "Run Minecraft Backup Service Daily";
    unitConfig.ConditionUser = "greyberet";
    timerConfig = {
      OnCalendar = "daily";
    };
    wantedBy = ["timers.target"];
  };
}
