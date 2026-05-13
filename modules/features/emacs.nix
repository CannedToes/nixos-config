{ ... }: {
  flake.nixosModules.emacs = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      emacs-pgtk
      coreutils
      clang
    ];
    services.emacs = {
      enable = true;
      install = true;
      package = pkgs.emacs-pgtk;
    };
  };
}
