{
  # here is where you will define all the sources where your nixos configuration will fetch from
  inputs = {
    # the root of all nix
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # all jokes aside here is the current most recent stable branch (kind of useless because of flakes IMO)
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11"

    # an official nixos repository that contains some qol modules you can import for specific hardware and the quirks that the hardware scan didn't pick up
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # WSL compatability module for NixOS (just for me since i'm a stinky gamer who uses windows but still need nix functionality on it)
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    # Home environment and dotfiles manager (i have left the url here for potential use but to be clear, HOME MANAGER SUCKS AND I HATE IT)
    #home-manager.url = "github:nix-community/home-manager";
    #home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Pre built nix-index database for... indexing your nix database (find outputs using 'nix-locate' and recommend missing packages you tried to use a command from)
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Effortless secrets management using age encryption and other methods
    sops-nix.url = "github:mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Container composer for running services and orchestrating/creating your own nix based containers that integrate with nixos
    arion.url = "github:hercules-ci/arion";
    arion.inputs.nixpkgs.follows = "nixpkgs";

    # flake parts is basically just a schema for flake modules so they are more standardized and easier to take care of
    flake-parts.url = "github:hercules-ci/flake-parts";

    # import tree just lets you import a whole directory recursively (tree) of nix files, check the outputs of this flake to see how it is used
    import-tree.url = "github:vic/import-tree";

    # these are some miscellaneous wrapper modules that can be used to configure some programs without home manager so it is user agnostic (i think)
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
  };

  # and here is where you will define where the sources end up and how you can use them
  # usually you would define every machine and module it uses and stuff here but dendritic allows us to compartmentalize that into different files under the modules folder
  outputs = inputs: inputs.flake-parts.lib.mkFlake
    { inherit inputs; }
    (inputs.import-tree ./modules);

  # the gist of it is you put stuff in and you get stuff out, but the stuff that comes out of-course relies on the stuff that comes in
  # so when you init your config it will freeze all your inputs TO THE COMMIT and save it to the flake.lock file
  # and since nix is a deterministic language if you always have the same inputs sources you will always get the same outputs, making it basically completely reproducible
}
