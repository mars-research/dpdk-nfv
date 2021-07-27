let
  rust-overlay = builtins.fetchTarball {
    url = "https://github.com/oxalica/rust-overlay/archive/bb00ab948702b4170914064263b37eff0b122471.tar.gz";
    sha256 = "0q6fbclal5nddk6lsblz1gnd6zvywbljd7qgfkgzzlwm199qvq3p";
  };

  # Allows DPDK to be built with example programs
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/zhaofengli/nixpkgs/archive/2dea83bfea51621940a355132cc55db0bed6038f.tar.gz";
    sha256 = "1div3mk6g8kdny9m7j5w5ccjrgn66qcvy894w66zs3f7qqc1ma8r";
  };
  pkgs = import nixpkgs {
    overlays = [
      (import rust-overlay)
      (self: super: {
        dpdk = super.dpdk.override {
          withExamples = [ "all" ];
        };
      })
    ];
  };
in pkgs.mkShell {
  buildInputs = with pkgs; [
    rust-bin.nightly."2021-07-26".complete
    dpdk
    libbsd
    boost
    meson
    ninja
    nasm
    linuxPackages.perf
    (pkgs.writeScriptBin "sperf" ''
      sudo ${linuxPackages.perf}/bin/perf "$@"
    '')
  ];
  nativeBuildInputs = with pkgs; [
    gcc11
    pkg-config 
  ];
}
