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

      import security_headers

      # Define specific headers *after* importing the snippet to allow overrides
      header {
        # Conditional Content-Security-Policy (overrides the default if needed)
        Content-Security-Policy "${
      if vh.host == "jankclient.greysilly7.xyz"
      then
        # Allow unsafe inline/eval, connections to self/spacebar/any, hCaptcha, and reCAPTCHA for jankclient
        "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://js.hcaptcha.com https://*.hcaptcha.com https://www.google.com/recaptcha/ https://www.gstatic.com/recaptcha/; frame-src https://*.hcaptcha.com https://www.google.com/recaptcha/ https://recaptcha.google.com/recaptcha/; connect-src 'self' *.${rootSBDomain} * https://*.hcaptcha.com;"
      else if vh.host == "vaultwarden.greysilly7.xyz"
      then
        # Allow Vaultwarden's inline scripts
        "script-src 'self' 'unsafe-inline'; connect-src 'self';"
      else
        # Default stricter policy for other hosts
        "script-src 'self'; connect-src 'self';" # Added connect-src 'self' for consistency
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

    (cors) {
      @cors_preflight method OPTIONS
      @cors header Origin {re.Match('.*')} # Match any Origin header

      handle @cors_preflight {
        # Remove potential duplicate header from backend first
        header -Access-Control-Allow-Origin
        # Set permissive CORS headers for preflight
        header Access-Control-Allow-Origin "*"
        header Access-Control-Allow-Methods *
        header Access-Control-Allow-Headers *
        header Access-Control-Max-Age "86400" # 24 hours
        respond "" 204
        # Prevent further processing for preflight
      }

      handle @cors {
        # Remove potential duplicate header from backend first
        header -Access-Control-Allow-Origin
        # Set permissive CORS headers for actual requests
        header Access-Control-Allow-Origin "*"
        # Expose headers if needed by the client (optional)
        # header Access-Control-Expose-Headers "Link, X-Total-Count"
      }
    }

    (security_headers) {
      header {
        # Security Headers
        Strict-Transport-Security "max-age=31536000; includeSubdomains; preload"
        X-Frame-Options "DENY"
        X-Content-Type-Options "nosniff"
        Referrer-Policy "strict-origin-when-cross-origin"
        Permissions-Policy "interest-cohort=()"
      }
    }

    greysilly7.xyz {
      root * ${inputs.greysilly7-xyz}
      encode zstd gzip
      file_server

      import security_headers

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
