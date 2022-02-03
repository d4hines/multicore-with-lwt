{
  description = "playing around with OCaml, Go, and Unix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        devShell = (pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gopls
            cowsay
          ];
        });
    in
    {
      inherit devShell;
    }
  );
}