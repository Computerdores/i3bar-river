{
  description = "Hyprland-only build of i3bar-river";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

    in
    {
      packages.${system}.default = pkgs.rustPlatform.buildRustPackage {
        pname = "i3bar-river";
        version = "1.1.0-hypr";

        src = ./.;
        cargoHash = "sha256-8sub8cXC/1iDY6v/9opO4FiLAo9CFrGJSDPNQydGvhQ=";

        cargoBuildFlags = [
          "--no-default-features"
          "--features=hyprland"
        ];

        nativeBuildInputs = [ pkgs.pkg-config ];
        buildInputs = [ pkgs.pango ];

        cargoRelease = true;

        meta = with pkgs.lib; {
          description = "Fork of i3bar-river Hyprland-only";
          homepage = "https://github.com/EdwinLeeford/i3bar-river";
          license = licenses.gpl3Only;
          mainProgram = "i3bar-river";
        };

      };
    };
}
