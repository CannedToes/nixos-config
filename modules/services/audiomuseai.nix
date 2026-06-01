{...}: {
  flake.nixosModules.audiomuseai = {config, ...}: {
    sops.secrets.audiomuseai = {};

    virtualisation.oci-containers.backend = "podman";

    virtualisation.oci-containers.containers = {
      audiomuse-redis = {
        image = "redis:7-alpine";
        autoStart = true;
        # ports = [ "6379:6379" ];
        volumes = [
          "audiomuse-redis-data:/data"
        ];
      };

      audiomuse-postgres = {
        image = "postgres:15-alpine";
        autoStart = true;
        # ports = [ "5432:5432" ];
        environment = {
          # POSTGRES_USER = "audiomuse";
          # POSTGRES_PASSWORD = "audiomusepassword";
          POSTGRES_DB = "audiomusedb";
        };

        environmentFiles = [
          config.sops.secrets.audiomuseai.path
        ];

        volumes = [
          "audiomuse-postgres-data:/var/lib/postgresql/data"
        ];
      };

      audiomuse-ai-flask = {
        image = "ghcr.io/neptunehub/audiomuse-ai:latest";
        autoStart = true;
        ports = ["8000:8000"];
        dependsOn = [
          "audiomuse-redis"
          "audiomuse-postgres"
        ];

        environment = {
          TZ = config.time.timeZone;
          SERVICE_TYPE = "flask";
          # POSTGRES_USER = "audiomuse";
          # POSTGRES_PASSWORD = "audiomusepassword";
          POSTGRES_DB = "audiomusedb";
          POSTGRES_HOST = "audiomuse-postgres";
          POSTGRES_PORT = "5432";
          REDIS_URL = "redis://audiomuse-redis:6379/0";
          TEMP_DIR = "/app/temp_audio";
        };

        environmentFiles = [
          config.sops.secrets.audiomuseai.path
        ];

        volumes = [
          "audiomuse-temp-flask:/app/temp_audio"
        ];
      };

      audiomuse-ai-worker = {
        image = config.virtualisation.oci-containers.containers.audiomuse-ai-flask.image;
        autoStart = true;
        dependsOn = [
          "audiomuse-redis"
          "audiomuse-postgres"
        ];

        environment = {
          TZ = config.time.timeZone;
          SERVICE_TYPE = "worker";
          # POSTGRES_USER = "audiomuse";
          # POSTGRES_PASSWORD = "audiomusepassword";
          POSTGRES_DB = "audiomusedb";
          POSTGRES_HOST = "audiomuse-postgres";
          POSTGRES_PORT = "5432";
          REDIS_URL = "redis://audiomuse-redis:6379/0";
          TEMP_DIR = "/app/temp_audio";
        };

        environmentFiles = [
          config.sops.secrets.audiomuseai.path
        ];

        volumes = [
          "audiomuse-temp-worker:/app/temp_audio"
        ];
      };
    };
  };
}
