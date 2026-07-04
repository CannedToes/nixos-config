{ ... }: {
	flake.nixosModules.mealie = { ... }: {
		services.mealie = {
			enable = true;
			database.createLocally = true;
		};
	};
}
