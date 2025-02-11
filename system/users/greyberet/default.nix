{
  pkgs,
  config,
  ...
}: {
  sops.secrets.greyberet_pass.neededForUsers = true;

  users.users.greyberet = {
    isNormalUser = true;
    extraGroups = [];
    homix = false;
    shell = pkgs.bash;
    hashedPasswordFile = config.sops.secrets.greyberet_pass.path;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDN8xvkZaXb1MkS04drQe+ncKoTrquupDKHlBqiQTUoWu5uqINh+SgEIgsmTsrCZPBahnxxcFvj8RM7f7ndBew5lwsEJ3uX1P2s2iRHkw12cRiajXSmqi1JR5lZv3CwT5KwQg9lTyDBhLINuBdysLEdOa/wYmH07Wz1y6uQh+LEHjYqqhdW8wxL7pV/5cG8jNF5E3y99nnIOFXvbtTm6IQHwOLj/VJzfjao/p8thUaZQyhUAQuZXVZnK3eCSqwE7TRv4MILQw0ntjRutUQsBXPoJskaDZY5eZzmGQyNbEoF99BtGVVP/EL7Da1cDhzkl3UvFj1g8TTJEipi8O2CEB2SqLlQPvINl25+lQ1zGxaUCF6YUvprsrVdjRetRLZy6hrhD66lDlYXOhZCensifUpXp/OEt79biHYFA1VnFJknwOWMPIMiwVfM2pG2cSbIOmBX8ApO01m8vOLdgvWtTqH+NyMzGppO/WmhZcgD1JP+CZBuBjc/4Hyd6Cka4mbqxos= win@DESKTOP-73F9F12"
    ];
    packages = [pkgs.openjdk21 pkgs.wget pkgs.curl pkgs.tmux pkgs.packwiz pkgs.git];
  };
}
