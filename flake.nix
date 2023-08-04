{
  description = "DPDK NFV tests";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/8afc4e543663ca0a6a4f496262cd05233737e732";
    rust-overlay.url = "github:oxalica/rust-overlay";
    mars-std = {
      url = "github:mars-research/mars-std";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
  };

  outputs = { self, mars-std, ... }: let
    supportedSystems = [ "x86_64-linux" ];
  in mars-std.lib.eachSystem supportedSystems (system: let
    pkgs = mars-std.legacyPackages.${system};
  in {
    devShell = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        rust-bin.nightly."2023-01-01".complete
        meson
        ninja
        nasm
        gcc11
        pkg-config

        python3
        linuxPackages.perf
        (pkgs.writeScriptBin "sperf" ''
          sudo ${linuxPackages.perf}/bin/perf "$@"
        '')

        gdb
      ];

      buildInputs = with pkgs; [
        (dpdk.override { withExamples = [ "all" ]; })
        libbsd
        papi
      ];
    };

    reproduce = pkgs.mars-research.mkReproduceHook {
      requirements = {
        cloudlab = "c220g2";
      };
      script = ''
        echo Dummy
      '';
    };
  });
}
