final: _: {
  git-dt = final.callPackage (
    {
      stdenv,
      lib,
      fetchurl,
      dpkg,
      # installShellFiles,
      makeWrapper,
      gawk,
      gnused,
      libxml2,
    }:
    stdenv.mkDerivation rec {
      name = "git-dt";
      version = "4.2.5-1-1";

      src = fetchurl {
        url = "https://captain.rtf.siemens.net/artifactory/simaticnet_wss_gitdt-stable-debian-egll/pool/git-dt_${version}_all.deb";
        hash = "sha256-eFqsqF8q4u1c8ev1TXczcmXr9IjBRGnJe1A79sNucQE=";
      };

      buildInputs = [
        dpkg
      ];

      nativeBuildInputs = [
        makeWrapper
        # installShellFiles
      ];

      unpackPhase = ''
        dpkg-deb --fsys-tarfile $src | tar --extract --no-same-owner
        mv usr $out
        mkdir $out/bin
        ln -s $out/lib/git-core/git-dt $out/bin
      '';

      installPhase = ''
        # Patch main script
        sed -i "s|sourcePath=.*|sourcePath=$out/lib/git-core|" $out/lib/git-core/git-dt

        # Patch lib
        sed -i "s|XMLLINT=.*|XMLLINT=${libxml2}/bin/xmllint|" $out/lib/git-core/dt_lib
        sed -i "s|AWK=.*|AWK=${gawk}/bin/awk|" $out/lib/git-core/dt_lib
        sed -i "s|SED=.*|SED=${gnused}/bin/sed|" $out/lib/git-core/dt_lib

        wrapProgram $out/bin/git-dt \
        --prefix PATH ":" ${
          lib.makeBinPath [
            gawk
            gnused
            libxml2
          ]
        }
      '';

      # postInstall = ''
      #   for shell in bash zsh; do
      #     installShellCompletion --cmd git \
      #       --$shell $out/share/bash-completion/completions/git
      #   done
      # '';
    }
  ) { };
}
