{...}: {
  flake.nixosModules.homeAssistant = {pkgs, ...}: let
    haosImage = pkgs.fetchurl {
      url = "https://github.com/home-assistant/operating-system/releases/download/17.3/haos_ova-17.3.qcow2.xz";
      hash = "sha256-1C+t+AbAaQeSpEYP86csKEbE4W4gM6760INWYuepaW8=";
    };
  in {
    environment.systemPackages = [pkgs.qemu_kvm];

    systemd.tmpfiles.rules = [
      "d /var/lib/haos 0750 root root - -"
    ];

    systemd.services.haos-vm = {
      description = "Home Assistant OS VM";
      after = ["network-online.target" "nginx.service"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      path = with pkgs; [
        coreutils
        iproute2
        qemu_kvm
        xz
      ];

      preStart = ''
        set -euo pipefail

        install -d -m 0750 /var/lib/haos

        if [ ! -e /var/lib/haos/OVMF_VARS.fd ]; then
          cp ${pkgs.OVMF.fd}/FV/OVMF_VARS.fd /var/lib/haos/OVMF_VARS.fd
          chmod 0600 /var/lib/haos/OVMF_VARS.fd
        fi

        if [ ! -e /var/lib/haos/haos.qcow2 ]; then
          xz -dc ${haosImage} > /var/lib/haos/haos.qcow2.tmp
          qemu-img resize /var/lib/haos/haos.qcow2.tmp 32G
          mv /var/lib/haos/haos.qcow2.tmp /var/lib/haos/haos.qcow2
          chmod 0600 /var/lib/haos/haos.qcow2
        fi

        ip link delete haos0 2>/dev/null || true
        ip tuntap add dev haos0 mode tap
        ip link set haos0 master br0
        ip link set haos0 up
      '';

      serviceConfig = {
        ExecStart = ''
          ${pkgs.qemu_kvm}/bin/qemu-system-x86_64 \
            -name haos \
            -machine q35,accel=kvm \
            -cpu host \
            -smp 2 \
            -m 2048 \
            -drive if=pflash,format=raw,readonly=on,file=${pkgs.OVMF.fd}/FV/OVMF_CODE.fd \
            -drive if=pflash,format=raw,file=/var/lib/haos/OVMF_VARS.fd \
            -drive file=/var/lib/haos/haos.qcow2,if=virtio,format=qcow2,cache=writeback,discard=unmap \
            -netdev tap,id=lan0,ifname=haos0,script=no,downscript=no \
            -device virtio-net-pci,netdev=lan0,mac=52:54:00:12:34:56 \
            -netdev user,id=proxy0,hostfwd=tcp:127.0.0.1:8123-:8123 \
            -device virtio-net-pci,netdev=proxy0,mac=52:54:00:12:34:57 \
            -device virtio-rng-pci \
            -display none \
            -serial mon:stdio
        '';
        ExecStopPost = "-${pkgs.iproute2}/bin/ip link delete haos0";
        Restart = "always";
        RestartSec = "10s";
        KillSignal = "SIGTERM";
        TimeoutStopSec = "60s";
      };
    };

    services.nginx.virtualHosts."home.myles.onl" = {
      useACMEHost = "myles.onl";
      forceSSL = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://192.168.1.76:8123";
        proxyWebsockets = true;
      };
    };
  };
}
