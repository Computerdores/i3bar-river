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
      buildPackageWith = cargoFlags: suffix: pkgs.rustPlatform.buildRustPackage {
        pname = cargoToml.package.name;
        version = cargoToml.package.version + suffix;

        src = ./.;

        cargoLock.lockFile = ./Cargo.lock;

        cargoBuildFlags = cargoFlags;

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
      buildForWM = wm: buildPackageWith [ "--no-default-features" ("--features="+wm) ] ("-" + wm);
      wms = [ "river" "niri" "hyprland" ];
    in {
      packages = (builtins.listToAttrs (map (wm: { name = wm; value = buildForWM wm; }) wms)) // {
        default = buildPackageWith [] "";
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
