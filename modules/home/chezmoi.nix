{ self, inputs, ... }: {

  flake.nixosModules.chezmoi = { pkgs, lib, ... }: {

    # DO NOT USE THIS MODULE UNLESS YOU ARE ME!!! (or edit it)
    system.activationScripts.dotfiles = {
      text = ''
        CHEZMOI_DIR="/home/myles/.local/share/chezmoi"
        HOME_DIR="/home/myles"

        if [ ! -d "$HOME_DIR" ]; then
          echo "WARNING: Home directory $HOME_DIR does not exist yet, skipping chezmoi init."
          exit 0
        fi

        if [ ! -d "$CHEZMOI_DIR" ]; then
          echo "Initializing chezmoi dotfiles..."
          ${pkgs.util-linux}/bin/runuser -l myles -c "${pkgs.chezmoi}/bin/chezmoi init --apply https://github.com/CannedToes/dotfiles.git"
        fi
      '';
      deps = [ "users" "groups" ];
    };

  };

}
