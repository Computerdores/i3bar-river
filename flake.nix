{
  description = "Hyprland-only build of i3bar-river";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs { inherit system overlays; };
      cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
    in {
      packages.default = pkgs.rustPlatform.buildRustPackage {
        pname = cargoToml.package.name;
        version = cargoToml.package.version + "-hypr";

        src = ./.;

        cargoLock.lockFile = ./Cargo.lock;

        cargoBuildFlags = [
          "--no-default-features"
          "--features=hyprland"
        ];

        nativeBuildInputs = [ pkgs.pkg-config ];
        buildInputs = [ pkgs.pango ];

        cargoRelease = true;

        meta = with pkgs.lib; {
          description = cargoToml.package.description;
          homepage = cargoToml.package.repository;
          license = licenses.gpl3Only;
          mainProgram = "i3bar-river";
        };
      };

      devShells.default = with pkgs; mkShell {
        nativeBuildInputs = [ pkgs.pkg-config ];
        buildInputs = [
          pango
          (rust-bin.beta.latest.default.override {
            extensions = [ "rust-src" ];
          })
        ];
      };
    }
  );
}
