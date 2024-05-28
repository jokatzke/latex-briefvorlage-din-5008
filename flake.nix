{
  description = "Nix Flake for latex-briefvorlage-din-5008";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      my-tex = (
        pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-small
            eurosym
            babel
            pdfpages
            hyperref
            ;
        }
      );
      mk-letter =
        file:
        pkgs.stdenvNoCC.mkDerivation {
          name = (builtins.baseNameOf file);
          src = self;
          buildInputs = [
            pkgs.coreutils
            my-tex
          ];
          phases = [
            "unpackPhase"
            "buildPhase"
            "installPhase"
          ];
          buildPhase = ''
            pdflatex ${file}
          '';
          installPhase = ''
            mkdir -p $out
            cp *.pdf $out/
          '';
        };
    in
    {
      packages.${system} = {
        letter = mk-letter ./Latex-Briefvorlage.tex;
        default = self.outputs.packages.${system}.letter;
      };
      devShells.${system}.default = pkgs.mkShell { buildInputs = [ my-tex ]; };
    };
}
