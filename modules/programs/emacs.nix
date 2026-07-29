{...}: {
  flake.nixosModules.emacs = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      emacs-pgtk
      clang
      findutils
      libvterm
      hunspell
      hunspellDicts.en_US
      shellcheck
      graphviz
    ];

    services.emacs = {
      enable = true;
      install = true;
      package = pkgs.emacs-pgtk;
    };
  };
}
