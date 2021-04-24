{ lib, python3Packages, fetchFromGitHub, ... }:

python3Packages.buildPythonApplication rec {
  pname = "alohomora";
  version = "2.4.0-lonocloud";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "LonoCloud";
    repo = "alohomora";
    rev = "2e82679a9e581ebdee5a407fa93e0c7de4ad197f";
    sha256 = "0c7dji4wh0jc67s0nc7w5hzc6b4dvc69hp5psk40208wg5y5sw0p";
  };

  doCheck = false;

  propagatedBuildInputs = with python3Packages; [ beautifulsoup4 boto3 python-u2flib-host requests ];

  meta = with lib; {
    homepage = "https://github.com/Viasat/alohomora/";
    description = "Get AWS API keys for a SAML-federated identity";
    license = licenses.asl20;
    maintainers = with maintainers; [ dwhittington ];
  };
}
