{
  description = "Stanford CS143 Compiler COOL C++";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-25.11;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
    # with flake-utils.lib; eachSystem allSystems (system:
    with flake-utils.lib; eachSystem ["x86_64-linux" "aarch64-darwin"] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # riscvCross = import nixpkgs {
        #   localSystem = "${system}";
        #   crossSystem = {
        #     config = "riscv64-unknown-linux-gnu";
        #   };
        # };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            flex_2_5_35
            bison
            clang-tools # for clangd lsp

            cmake
            gcc
          ];
        };
      });
}
