{
  description = "DPDK NFV tests";

  inputs = {
    mars-std.url = "git+ssh://git@github.com/mars-research/mars-std";
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

        linuxPackages.perf
        (pkgs.writeScriptBin "sperf" ''
          sudo ${linuxPackages.perf}/bin/perf "$@"
        '')
      ];

      buildInputs = with pkgs; [
        dpdk
        libbsd
        boost
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