{
  nodes = {
    greyserver = {
      name = "Grey Server";
      deviceType = "nixos";
    };
    mcserv = {
      name = "Minecraft Server";
      deviceType = "nixos";
    };
    truenas = {
      name = "TrueNAS";
      deviceType = "device";
    };
    switch = {
      name = "Switch";
      deviceType = "device";
    };
  };
  networks.home = {
    name = "Home Network";
    cidrv4 = "192.168.1.1/24";
  };
}
