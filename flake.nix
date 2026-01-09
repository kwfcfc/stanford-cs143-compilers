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
        devShells.default = let
          # scripts for referene compiler components
          coolc = pkgs.stdenv.mkDerivation {
            name = "coolc";
            src = ./bin;

            installPhase = ''
              mkdir -p $out/bin
              cp -r . $out/bin/
              chmod +x $out/bin/*
            '';
          };
        in
          pkgs.mkShell {
            packages = [
              coolc
            ];
            buildInputs = with pkgs; [
              git
              flex_2_5_35
              bison
              clang-tools # for clangd lsp

              # perl and sed for grading script
              perl
              gnused

              #

              cmake
              gcc
            ];
          };

        # shellHook 会在进入 nix develop 时运行
        shellHook = ''
          # echo "fixing script executable path..."
          # patchShebangs scripts
          patchShebangs ./assignments/
        '';
      });
}
