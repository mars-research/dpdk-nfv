{
  description = "DPDK NFV tests";

  inputs = {
    mars-std.url = "github:mars-research/mars-std/0d999a347e53f400e771392b48128471d5b0a098";
    mars-std.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
  };

  outputs = { self, mars-std, ... }: let
    supportedSystems = [ "x86_64-linux" ];
  in mars-std.lib.eachSystem supportedSystems (system: let
    pkgs = mars-std.legacyPackages.${system};
  in {
    devShell = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        rust-bin.nightly."2021-07-26".complete
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
