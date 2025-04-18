{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  rootSBDomain = "spacebar.greysilly7.xyz";

  virtualHosts = [
    {
      host = "vaultwarden.greysilly7.xyz";
      port = toString config.services.vaultwarden.config.ROCKET_PORT;
      extraConfig = null;
    }
    {
      host = "spacebar.greysilly7.xyz";
      port = "3001";
      extraConfig = ''
        reverse_proxy /media http://127.0.0.1:8000
      '';
    }
    {
      host = "api-spacebar.greysilly7.xyz";
      port = "3001";
      extraConfig = null;
    }
    {
      host = "cdn-spacebar.greysilly7.xyz";
      port = "3003";
      extraConfig = null;
    }
    {
      host = "gateway-spacebar.greysilly7.xyz";
      port = "3002";
      extraConfig = null;
    }
    {
      host = "jankclient.greysilly7.xyz";
      port = "8080";
      extraConfig = null;
    }
  ];

  caddyHost = vh: ''
    ${vh.host} {
      reverse_proxy http://127.0.0.1:${vh.port} {
        header_up Host {host}
        header_up X-Real-IP {remote}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Proto {scheme}
      }

      ${
      if vh.extraConfig != null
      then vh.extraConfig
      else ""
    }

      header {
        # Security Headers
        Strict-Transport-Security "max-age=31536000; includeSubdomains; preload"
        Content-Security-Policy "${
      if vh.host == "jankclient.greysilly7.xyz"
      # Allow unsafe inline scripts and eval for jankclient, and ensure 'self' covers external scripts from the same origin
      then "script-src 'self' 'unsafe-inline' 'unsafe-eval';"
      # Default stricter policy for other hosts
      else "script-src 'self';"
    }"
      }

      log {
        output file /var/log/caddy/${vh.host}.log
      }
    }
  '';

  caddyfileContent = ''
    {
      email greysilly7@gmail.com
      acme_ca https://acme-v02.api.letsencrypt.org/directory
    }

    greysilly7.xyz {
      root * ${inputs.greysilly7-xyz}
      encode zstd gzip
      file_server

      @spacebar {
        path /.well-known/spacebar
      }
      handle @spacebar {
        header Access-Control-Allow-Origin "*"
        header Content-Type application/json
        respond `{
          "api": "https://api-${rootSBDomain}/api/v9"
        }`
      }

      handle_path /jankwrapper* {
        reverse_proxy http://127.0.0.1:7878
      }

      header {
        # Security Headers
        Strict-Transport-Security "max-age=31536000; includeSubdomains; preload"
        Referrer-Policy "origin-when-cross-origin"
        X-Frame-Options "DENY"
        X-Content-Type-Options "nosniff"
      }

      log {
        output file /var/log/caddy/greysilly7.xyz.log
      }
    }

    ${lib.concatStringsSep "\n\n" (map caddyHost virtualHosts)}
  '';
in {
  services.caddy = {
    enable = true;
    configFile = pkgs.writeText "Caddyfile" caddyfileContent;
  };

  networking.firewall.allowedTCPPorts = [80 443];
  networking.firewall.allowedUDPPorts = [443];
}
