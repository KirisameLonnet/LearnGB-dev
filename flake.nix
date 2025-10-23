{
  description = "A Nix Flake for Game Boy (GB/GBC) development on Linux and arm64 macOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          default = pkgs.mkShell {
            name = "gb-dev-shell";

            buildInputs = with pkgs; [
              rgbds
            ];

            shellHook = ''
              echo "--- Game Boy Development Environment ---"
              echo "Tools available: lcc, rgbasm, emulicious-qt, make"
              echo "--------------------------------------"
            '';
          };
        });
    };
}