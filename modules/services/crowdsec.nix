# After first deploy, run these to complete setup:
#   cscli collections install crowdsecurity/nginx
#   cscli collections install crowdsecurity/sshd
#   cscli collections install crowdsecurity/linux
#   cscli collections install crowdsecurity/http-cve
#   cscli collections install crowdsecurity/base-http-scenarios
#   cscli collections install crowdsecurity/http-probing
#   cscli decisions import
{...}: {
  flake.nixosModules.crowdsec = {...}: {
    services.crowdsec = {
      enable = true;

      settings = {
        common = {
          daemonize = true;
          auto_update = true;
        };

        api = {
          server = {
            listen_uri = "127.0.0.1:8080";
          };
          client = {
            auto_registration = true;
          };
          console = {
            share_tactical = false;
            share_custom = false;
          };
        };

        config = {
          simulation_mode = false;
        };
      };

      acquisitions = [
        {
          source = "journalctl";
          journalctl_filter = ["_SYSTEMD_UNIT=sshd.service"];
          labels.type = "syslog";
        }
        {
          source = "file";
          filenames = ["/var/log/nginx/access.log"];
          labels.type = "nginx";
        }
        {
          source = "file";
          filenames = ["/var/log/nginx/error.log"];
          labels.type = "nginx";
        }
        {
          source = "journalctl";
          journalctl_filter = ["_SYSTEMD_UNIT=systemd-logind.service"];
          labels.type = "syslog";
        }
      ];
    };

    services.crowdsec-firewall-bouncer = {
      enable = true;
      settings = {
        api_url = "http://127.0.0.1:8080";
        disable_ipv6 = false;
        mode = "nftables";
      };
    };
  };
}
