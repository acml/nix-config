{ buildPythonPackage
, cffi
, fetchPypi
, lib
, pytestCheckHook
, pytestrunner
}:

buildPythonPackage rec {
  pname = "reflink";
  version = "0.2.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-ySU1gtskQTv9cDq/wbKkneePMbSQcjnyhumhkpoebjo=";
  };

  propagatedBuildInputs = [ cffi pytestrunner ];

  checkInputs = [ pytestCheckHook ];

  # FIXME: Figure out how to get these working.
  doCheck = false;

  meta = with lib; {
    description = "Python reflink wraps around platform specific reflink implementations";
    homepage = "https://gitlab.com/rubdos/pyreflink";
    license = licenses.mit;
    maintainers = with maintainers; [ lovesegfault ];
  };
}
