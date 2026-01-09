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
      in {
        devShells.default =
          let
            coolc = pkgs.stdenv.mkDerivation {
              name = "coolc";
              src = ./bin;

              # add for dirname
              buildInputs = [ pkgs.coreutils ];

              installPhase = ''
                mkdir -p $out/bin
                cp -r . $out/bin

                substituteInPlace $out/bin/anngen \
                  --replace "/usr/bin/dirname" "${pkgs.coreutils}/bin/dirname"
                substituteInPlace $out/bin/aps2c++ \
                  --replace "/usr/bin/dirname" "${pkgs.coreutils}/bin/dirname"
                substituteInPlace $out/bin/aps2java \
                  --replace "/usr/bin/dirname" "${pkgs.coreutils}/bin/dirname"
                substituteInPlace $out/bin/cgen \
                  --replace "/usr/bin/dirname" "${pkgs.coreutils}/bin/dirname"
                substituteInPlace $out/bin/coolc \
                  --replace "/usr/bin/dirname" "${pkgs.coreutils}/bin/dirname"
                substituteInPlace $out/bin/lexer \
                  --replace "/usr/bin/dirname" "${pkgs.coreutils}/bin/dirname"
                substituteInPlace $out/bin/parser \
                  --replace "/usr/bin/dirname" "${pkgs.coreutils}/bin/dirname"
                substituteInPlace $out/bin/semant \
                  --replace "/usr/bin/dirname" "${pkgs.coreutils}/bin/dirname"
                substituteInPlace $out/bin/spim \
                  --replace "/usr/bin/dirname" "${pkgs.coreutils}/bin/dirname"
                substituteInPlace $out/bin/xspim \
                  --replace "/usr/bin/dirname" "${pkgs.coreutils}/bin/dirname"
                chmod +x $out/bin/*
              '';
            };
          in
          pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              flex_2_5_35
              bison
              clang-tools # for clangd lsp

              # perl and sed for grading script
              perl
              gnused

              # coolc
              coolc

              cmake
              gcc
            ];

            shellHook = ''
              # add coolc to PATh
              # export PATH="$PWD/bin:$PATH"
              # echo "fixing script executable path..."
              # patchShebangs scripts
              patchShebangs ./assignments/
              # patchShebangs ./bin/
            '';
          };
      });
}
