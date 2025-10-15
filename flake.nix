{
  description = "A Nix Flake for Game Boy (GB/GBC) development on Linux";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let

      system = "x86_64-linux";


      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {

      devShells.${system}.default = pkgs.mkShell {
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
    };
}
