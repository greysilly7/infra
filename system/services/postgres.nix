{
  lib,
  pkgs,
  ...
}: {
  services.postgresql = {
    enable = true; # Enable PostgreSQL service
    package = pkgs.postgresqlVersions.postgresql_16_jit;
    enableTCPIP = true; # Enable TCP/IP connections

    ensureDatabases = ["spacebar" "vaultwarden" "iremia"]; # Ensure the "spacebar" database exists
    ensureUsers = [
      {
        name = "spacebar"; # Ensure the "spacebar" user exists
        ensureDBOwnership = true; # Ensure the user owns the database
      }
      {
        name = "vaultwarden";
        ensureDBOwnership = true;
      }
      {
        name = "iremia";
        ensureDBOwnership = true;
      }
    ];

    # Authentication configuration
    authentication = lib.mkOverride 10 ''
      # type  database  DBuser  origin-address  auth-method
      # Local connections
      local   all       all     trust
      # IPv4 connections
      host    all       all     127.0.0.1/32    trust
      # IPv6 connections
      host    all       all     ::1/128         trust


      # Allow local network
      host    all       all     100.99.73.3/24 trust
    '';

    # Ident map configuration
    identMap = ''
      # ArbitraryMapName  systemUser  DBUser
      superuser_map      root        postgres
      superuser_map      postgres    postgres
      # Let other names login as themselves
      superuser_map      /^(.*)$     \1
    '';

    settings = {
      # DISCLAIMER - Software and the resulting config files are provided AS IS - IN NO EVENT SHALL
      # BE THE CREATOR LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
      # DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION.

      # Connectivity
      max_connections = 100;
      superuser_reserved_connections = 3;

      # Memory Settings
      shared_buffers = "1024MB";
      work_mem = "32MB";
      maintenance_work_mem = "320MB";
      huge_pages = "off";
      effective_cache_size = "3GB";
      effective_io_concurrency = 1; # concurrent IO only really activated if OS supports posix_fadvise function
      random_page_cost = 4; # speed of random disk access relative to sequential access (1.0)

      # Monitoring
      shared_preload_libraries = "pg_stat_statements"; # per statement resource usage stats
      track_io_timing = "on"; # measure exact block IO times
      track_functions = "pl"; # track execution times of pl-language procedures if any

      # Replication
      wal_level = "replica"; # consider using at least 'replica'
      max_wal_senders = 0;
      synchronous_commit = "on";

      # Checkpointing
      checkpoint_timeout = "15min";
      checkpoint_completion_target = 0.9;
      max_wal_size = "10240MB";
      min_wal_size = "5120MB";

      # WAL writing
      wal_compression = "on";
      wal_buffers = -1; # auto-tuned by Postgres till maximum of segment size (16MB by default)
      wal_writer_delay = "200ms";
      wal_writer_flush_after = "1MB";

      # Background writer
      bgwriter_delay = "200ms";
      bgwriter_lru_maxpages = 100;
      bgwriter_lru_multiplier = 2.0;
      bgwriter_flush_after = 0;

      # Parallel queries
      max_worker_processes = 2;
      max_parallel_workers_per_gather = 1;
      max_parallel_maintenance_workers = 1;
      max_parallel_workers = 2;
      parallel_leader_participation = "on";

      # Advanced features
      enable_partitionwise_join = "on";
      enable_partitionwise_aggregate = "on";
      jit = "on";
      max_slot_wal_keep_size = "1000MB";
      track_wal_io_timing = "on";
      maintenance_io_concurrency = 1;
      wal_recycle = "on";

      # General notes:
      # Note that not all settings are automatically tuned.
      #   Consider contacting experts at
      #   https://www.cybertec-postgresql.com
      #   for more professional expertise.
    };
  };

  # Open Firewall
  networking.firewall.allowedTCPPorts = [5432];
}
