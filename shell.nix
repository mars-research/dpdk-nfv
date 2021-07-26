let
  rust-overlay = builtins.fetchTarball {
    url = "https://github.com/oxalica/rust-overlay/archive/41b11431e8dfa23263913bb96b5ef1913e01dfc1.tar.gz";
    sha256 = "0489dgd00ckq4imdl064v1c9l2hvblvji1mmc1x1mqpan5mpzcxf";
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
    rust-bin.nightly."2021-01-10".default
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
