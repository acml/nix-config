final: _: {
  git-critique = final.callPackage (
    {
      stdenv,
      lib,
      fetchFromGitHub,
      bash,
      git,
      makeWrapper,
    }:
    stdenv.mkDerivation {
      name = "git-critique";
      src = fetchFromGitHub {
        # https://github.com/zdk/git-critique
        owner = "zdk";
        repo = "git-critique";
        rev = "30f60208dbe3c3b6fbf2aa1612975cfbb45a387d";
        hash = "sha256-7pGpe2np8EmXgX5/zT/2BtIBOibY0tGXUHCBoJ0wyek=";
      };
      buildInputs = [
        bash
        git
      ];
      nativeBuildInputs = [ makeWrapper ];
      installPhase = ''
        mkdir -p $out/bin
        cp git-critique $out/bin/git-critique
        wrapProgram $out/bin/git-critique \
          --prefix PATH : ${
            lib.makeBinPath [
              bash
              git
            ]
          }
      '';
    }
  ) { };
}
