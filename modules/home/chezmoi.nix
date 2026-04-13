{ self, inputs, ... }: {

  flake.nixosModules.chezmoi = { pkgs, lib, ... }: {
    system.activationScripts.dotfiles = {
	text = ''
	  CHEZMOI_DIR="/home/myles/.local/share/chezmoi"
	    
	  if [ ! -d "$CHEZMOI_DIR" ]; then
	    echo "Initializing chezmoi dotfiles..."
	    ${pkgs.util-linux}/bin/runuser -l myles -c "${pkgs.chezmoi}/bin/chezmoi init --apply https://github.com/CannedToes/dotfiles.git"
	  fi
	'';
	deps = [];
    };
  };

}
