let
  pkgs = import <nixpkgs> {};
  secretName = "secret";
in
  pkgs.stdenv.mkDerivation {
    name = "test-decrypt";

    requiredSystemFeatures = [ "buildtime-secrets" ];
    requiredSecrets = [ (builtins.toJSON {
      name = secretName;
      hash = "";
    }) ];

    dontUnpack = true;

    buildPhase = ''
      ls -la /secrets
      ls -la /secrets/${secretName}
      cat /secrets/${secretName} > "$out"
    '';
  }
