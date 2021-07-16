let
  rust-overlay = builtins.fetchTarball {
    url = "https://github.com/oxalica/rust-overlay/archive/41b11431e8dfa23263913bb96b5ef1913e01dfc1.tar.gz";
    sha256 = "0489dgd00ckq4imdl064v1c9l2hvblvji1mmc1x1mqpan5mpzcxf";
  };
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/f641b66ceb34664f4b92d688916472f843921fd3.tar.gz";
    sha256 = "1hglx3c5qbng9j6bcrb5c2wip2c0qxdylbqm4iz23b2s7h787qsk";
  };
  pkgs = import nixpkgs {
    overlays = [
      (import rust-overlay)
    ];
  };
in pkgs.mkShell {
  buildInputs = [
    pkgs.rust-bin.nightly."2021-01-10".default
    pkgs.gcc11
  ];
}