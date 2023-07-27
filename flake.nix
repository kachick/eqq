{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/b5616857af88e74749862555ac46fe429192cc8c";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
    nixpkgs-ruby.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-ruby, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        ruby = nixpkgs-ruby.lib.packageFromRubyVersionFile {
          file = ./.ruby-version;
          inherit system;
        };
      in
      {
        devShells.default = with pkgs;
          mkShell {
            buildInputs = [
              ruby
              dprint
              nixd
              nixpkgs-fmt
              typos
              actionlint
            ];
          };
      }
    );
}
