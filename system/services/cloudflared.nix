{
  pkgs,
  config,
  lib,
  ...
}: let
  # Removed dyndnsScript variable
in {
  systemd.services.custom-dyndns = {
    description = "Custom Cloudflare Dynamic DNS Updater";
    # Removed preStart command
    script = ''
      #!${pkgs.bash}/bin/bash

      # Configuration
      # !!! SECURITY WARNING: Hardcoding secrets is not recommended. !!!
      # Consider using sops-nix or another secrets management solution.
      API_TOKEN="${config.sops.secrets.cftoken.path}" # Replace with your Cloudflare API token
      ZONE_NAME="greysilly7.xyz"                           # Replace with your domain name
      RECORD_NAME_A="greysilly7.xyz"                       # Replace with the DNS record for IPv4
      RECORD_NAME_AAAA="greysilly7.xyz"                    # Replace with the DNS record for IPv6
      PROXIED_A=true                                       # Set to true or false for IPv4 record
      PROXIED_AAAA=true                                    # Set to true or false for IPv6 record

      # Get the current public IPv4 and IPv6 addresses
      CURRENT_IPv4=$(${lib.getExe pkgs.curl} -s https://ipv4.myip.wtf/)
      CURRENT_IPv6=$(${lib.getExe pkgs.curl} -s https://myip.wtf/)

      # Get the DNS zone ID
      ZONE_ID=$(${lib.getExe pkgs.curl} -s -X GET "https://api.cloudflare.com/client/v4/zones?name=''${ZONE_NAME}" \
          -H "Authorization: Bearer ''${API_TOKEN}" \
          -H "Content-Type: application/json" | ${lib.getExe pkgs.jq} -r ".result[0].id")

      # Get the DNS record IDs for both A and AAAA records
      RECORD_ID_A=$(${lib.getExe pkgs.curl} -s -X GET "https://api.cloudflare.com/client/v4/zones/''${ZONE_ID}/dns_records?name=''${RECORD_NAME_A}&type=A" \
          -H "Authorization: Bearer ''${API_TOKEN}" \
          -H "Content-Type: application/json" | ${lib.getExe pkgs.jq} -r ".result[0].id")

      RECORD_ID_AAAA=$(${lib.getExe pkgs.curl} -s -X GET "https://api.cloudflare.com/client/v4/zones/''${ZONE_ID}/dns_records?name=''${RECORD_NAME_AAAA}&type=AAAA" \
          -H "Authorization: Bearer ''${API_TOKEN}" \
          -H "Content-Type: application/json" | ${lib.getExe pkgs.jq} -r ".result[0].id")

      # Get the current DNS record IPs
      RECORD_IPv4=$(${lib.getExe pkgs.curl} -s -X GET "https://api.cloudflare.com/client/v4/zones/''${ZONE_ID}/dns_records/''${RECORD_ID_A}" \
          -H "Authorization: Bearer ''${API_TOKEN}" \
          -H "Content-Type: application/json" | ${lib.getExe pkgs.jq} -r ".result.content")

      RECORD_IPv6=$(${lib.getExe pkgs.curl} -s -X GET "https://api.cloudflare.com/client/v4/zones/''${ZONE_ID}/dns_records/''${RECORD_ID_AAAA}" \
          -H "Authorization: Bearer ''${API_TOKEN}" \
          -H "Content-Type: application/json" | ${lib.getExe pkgs.jq} -r ".result.content")

      # Function to update DNS record
      update_record() {
          local zone_id=$1
          local record_id=$2
          local record_name=$3
          local record_type=$4
          local ip_address=$5
          local proxied=$6

          echo "Updating ''${record_type} record for ''${record_name} to ''${ip_address}"
          response=$(${lib.getExe pkgs.curl} -s -X PUT "https://api.cloudflare.com/client/v4/zones/''${zone_id}/dns_records/''${record_id}" \
              -H "Authorization: Bearer ''${API_TOKEN}" \
              -H "Content-Type: application/json" \
              --data "{\"type\":\"''${record_type}\",\"name\":\"''${record_name}\",\"content\":\"''${ip_address}\",\"ttl\":1,\"proxied\":''${proxied}}")

          # Basic check for success (Cloudflare API returns success:true on success)
          if echo "$response" | ${lib.getExe pkgs.jq} -e '.success' >/dev/null; then
              echo "''${record_type} record updated successfully."
          else
              echo "Failed to update ''${record_type} record. Response: $response"
          fi
      }

      # Update the A record if the IPv4 address has changed
      if [ "''${CURRENT_IPv4}" != "''${RECORD_IPv4}" ]; then
          echo "IPv4 address has changed. Old: ''${RECORD_IPv4}, New: ''${CURRENT_IPv4}"
          update_record "''${ZONE_ID}" "''${RECORD_ID_A}" "''${RECORD_NAME_A}" "A" "''${CURRENT_IPv4}" "''${PROXIED_A}"
      else
          echo "No update needed for A record. Current IPv4 is still ''${CURRENT_IPv4}."
      fi

      # Update the AAAA record if the IPv6 address has changed
      if [ "''${CURRENT_IPv6}" != "''${RECORD_IPv6}" ]; then
          echo "IPv6 address has changed. Old: ''${RECORD_IPv6}, New: ''${CURRENT_IPv6}"
          update_record "''${ZONE_ID}" "''${RECORD_ID_AAAA}" "''${RECORD_NAME_AAAA}" "AAAA" "''${CURRENT_IPv6}" "''${PROXIED_AAAA}"
      else
          echo "No update needed for AAAA record. Current IPv6 is still ''${CURRENT_IPv6}."
      fi
    '';
    # Provide necessary packages in the service's PATH
    path = [pkgs.bash pkgs.curl pkgs.jq pkgs.uutils-coreutils-noprefix]; # coreutils might not be strictly needed now
    # Run as a one-shot service
    serviceConfig = {
      Type = "oneshot";
      User = "root"; # Or another user if preferred, ensure permissions
    };
    # Wait for network to be online
    after = ["network-online.target"];
    wants = ["network-online.target"];
    # Add a restart policy to ensure the service runs reliably
    restart = "on-failure";
  };

  systemd.timers.custom-dyndns = {
    description = "Run Custom Cloudflare DDNS Updater periodically";
    wantedBy = ["timers.target"];
    timerConfig = {
      # Run 5 minutes after boot
      OnBootSec = "5min";
      # Run every 15 minutes thereafter
      OnUnitActiveSec = "15min";
      Unit = "custom-dyndns.service";
    };
  };
}
