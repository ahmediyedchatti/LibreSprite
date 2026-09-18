{
  description = "LibreSprite - Animated sprite editor & pixel art tool";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.stdenv.mkDerivation rec {
          pname = "libresprite";
          version = "unstable";

          # If you're building from a local clone, this points at it directly.
          # For a pinned/reproducible build instead, replace with:
          #   src = pkgs.fetchFromGitHub {
          #     owner = "LibreSprite";
          #     repo = "LibreSprite";
          #     rev = "<commit-hash>";
          #     sha256 = pkgs.lib.fakeSha256; # nix build will tell you the real one
          #     fetchSubmodules = true; # needed: third_party/simpleini and src/flic
          #   };
          src = pkgs.lib.cleanSourceWith {
            src = ./.;
            filter = path: type:
              baseNameOf path != "build" && baseNameOf path != "result";
          };

          nativeBuildInputs = with pkgs; [
            cmake
            ninja
            pkg-config
          ];

          buildInputs = with pkgs; [
            curl
            freetype
            giflib
            gtest
            libjpeg
            libtiff
            pixman
            libpng
            SDL2
            SDL2_image
            tinyxml-2
            nodejs
            zlib
            libarchive
            libX11
            libXext
            libXcursor
            libXi
          ];

          cmakeFlags = [
            "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
          ];

          # The repo's own instructions build the "libresprite" target
          # specifically rather than the default "all".
          ninjaFlags = [ "libresprite" ];

          installPhase = ''
            runHook preInstall
            ninja install
            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Animated sprite editor & pixel art tool (Aseprite fork)";
            homepage = "https://libresprite.github.io/";
            license = licenses.gpl2Only;
            platforms = platforms.linux;
            mainProgram = "libresprite";
          };
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.default ];
        };
      });
}
