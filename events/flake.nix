{
  description = "Events for pythoneda-realm-rydnr";
  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    pythoneda-shared-pythoneda-domain = {
      url =
        "github:pythoneda-shared-pythoneda/domain-artifact/0.0.1a26?dir=domain";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        description = "Events for pythoneda-realm-rydnr";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/pythoneda-realm-rydnr/events";
        maintainers = [ "rydnr <github@acm-sl.org>" ];
        nixpkgsRelease = "nixos-23.05";
        shared = import ./nix/shared.nix;
        pythoneda-realm-rydnr-events-for =
          { python, pythoneda-shared-pythoneda-domain, version }:
          let
            pname = "pythoneda-realm-rydnr-events";
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            pythonpackage = "pythoneda.realm.rydnr.events";
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            pyprojectTemplateFile = ./pyprojecttoml.template;
            pyprojectTemplate = pkgs.substituteAll {
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage pname pythonMajorMinorVersion pythonpackage
                version;
              package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
              pythonedaSharedPythonedaDomainVersion =
                pythoneda-shared-pythoneda-domain.version;
              src = pyprojectTemplateFile;
            };
            src = pkgs.fetchFromGitHub {
              owner = "pythoneda-realm-rydnr";
              repo = "events";
              rev = version;
              sha256 = "sha256-PprMHvDm3/WxdmUPUo0d1zgH+sCwOzmlT/9U0S0Xh8M=";
            };

            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip pkgs.jq poetry-core ];
            propagatedBuildInputs = with python.pkgs;
              [ pythoneda-shared-pythoneda-domain ];

            checkInputs = with python.pkgs; [ pytest ];

            pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              cp -r ${src} .
              sourceRoot=$(ls | grep -v env-vars)
              chmod +w $sourceRoot
              cp ${pyprojectTemplate} $sourceRoot/pyproject.toml
            '';

            postInstall = ''
              pushd /build/$sourceRoot
              for f in $(find . -name '__init__.py'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  cp $f $out/lib/python${pythonMajorMinorVersion}/site-packages/$f;
                fi
              done
              popd
              mkdir $out/dist
              cp dist/${wheelName} $out/dist
              jq ".url = \"$out/dist/${wheelName}\"" $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json > temp.json && mv temp.json $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
        pythoneda-realm-rydnr-events-0_0_1a1-for =
          { python, pythoneda-shared-pythoneda-domain }:
          pythoneda-realm-rydnr-events-for {
            version = "0.0.1a1";
            inherit python pythoneda-shared-pythoneda-domain;
          };
      in rec {
        packages = rec {
          pythoneda-realm-rydnr-events-0_0_1a1-python38 =
            pythoneda-realm-rydnr-events-0_0_1a1-for {
              python = pkgs.python38;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python38;
            };
          pythoneda-realm-rydnr-events-0_0_1a1-python39 =
            pythoneda-realm-rydnr-events-0_0_1a1-for {
              python = pkgs.python39;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python39;
            };
          pythoneda-realm-rydnr-events-0_0_1a1-python310 =
            pythoneda-realm-rydnr-events-0_0_1a1-for {
              python = pkgs.python310;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python310;
            };
          pythoneda-realm-rydnr-events-latest-python38 =
            pythoneda-realm-rydnr-events-0_0_1a1-python38;
          pythoneda-realm-rydnr-events-latest-python39 =
            pythoneda-realm-rydnr-events-0_0_1a1-python39;
          pythoneda-realm-rydnr-events-latest-python310 =
            pythoneda-realm-rydnr-events-0_0_1a1-python310;
          pythoneda-realm-rydnr-events-latest =
            pythoneda-realm-rydnr-events-latest-python310;
          default = pythoneda-realm-rydnr-events-latest;
        };
        defaultPackage = packages.default;
        devShells = rec {
          pythoneda-realm-rydnr-events-0_0_1a1-python38 = shared.devShell-for {
            package = packages.pythoneda-realm-rydnr-events-0_0_1a1-python38;
            python = pkgs.python38;
            pythoneda-shared-pythoneda-domain =
              pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python38;
            inherit pkgs nixpkgsRelease;
          };
          pythoneda-realm-rydnr-events-0_0_1a1-python39 = shared.devShell-for {
            package = packages.pythoneda-realm-rydnr-events-0_0_1a1-python39;
            python = pkgs.python39;
            pythoneda-shared-pythoneda-domain =
              pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python39;
            inherit pkgs nixpkgsRelease;
          };
          pythoneda-realm-rydnr-events-0_0_1a1-python310 = shared.devShell-for {
            package = packages.pythoneda-realm-rydnr-events-0_0_1a1-python310;
            python = pkgs.python310;
            pythoneda-shared-pythoneda-domain =
              pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python310;
            inherit pkgs nixpkgsRelease;
          };
          pythoneda-realm-rydnr-events-latest-python38 =
            pythoneda-realm-rydnr-events-0_0_1a1-python38;
          pythoneda-realm-rydnr-events-latest-python39 =
            pythoneda-realm-rydnr-events-0_0_1a1-python39;
          pythoneda-realm-rydnr-events-latest-python310 =
            pythoneda-realm-rydnr-events-0_0_1a1-python310;
          pythoneda-realm-rydnr-events-latest =
            pythoneda-realm-rydnr-events-latest-python310;
          default = pythoneda-realm-rydnr-events-latest;

        };
      });
}
