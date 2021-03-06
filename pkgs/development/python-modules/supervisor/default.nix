{ stdenv, lib, buildPythonPackage, isPy3k, fetchPypi
, mock
, meld3
, pytest
, setuptools
}:

buildPythonPackage rec {
  pname = "supervisor";
  version = "4.2.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "c479c875853e9c013d1fa73e529fd2165ff1ecaecc7e82810ba57e7362ae984d";
  };

  patches = [
    # SOMAXCONN limit of glibc-2.31 has been increased from 128 to 4096:
    # * https://sourceware.org/git/?p=glibc.git;a=commit;h=96958e2700f5b4f4d1183a0606b2b9848a53ea44
    # * https://github.com/Supervisor/supervisor/issues/1346
    ./glibc-2.31.patch
  ];

  # wants to write to /tmp/foo which is likely already owned by another
  # nixbld user on hydra
  doCheck = !stdenv.isDarwin;
  checkInputs = [ mock pytest ];
  checkPhase = ''
    pytest
  '';

  propagatedBuildInputs = [ meld3 setuptools ];

  meta = with lib; {
    description = "A system for controlling process state under UNIX";
    homepage = "http://supervisord.org/";
    license = licenses.free; # http://www.repoze.org/LICENSE.txt
    maintainers = with maintainers; [ zimbatm ];
  };
}
