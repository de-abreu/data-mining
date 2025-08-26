{
  description = "Data visualization development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    # Custom Python environment
    pythonEnv = pkgs.python3.withPackages (ps:
      with ps; [
        ipywidgets
        jupysql
        jupyter
        lsprotocol
        matplotlib
        pandas
        pandas-stubs
        plotly
        psycopg2
        pyqt6
        scikit-learn
        seaborn
        sqlalchemy
        tqdm
        types-psycopg2
      ]);
    dependencies = with pkgs; [
      dbeaver-bin
      postgresql
      sqlite
    ];

    runScript = pkgs.writeShellApplication {
      name = "launch-jupyter";
      runtimeInputs = dependencies;
      text = ''
        jupyter notebook ${self} # Launch Jupyter
      '';
    };
  in {
    # For `nix develop`
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [pythonEnv] ++ dependencies;
    };

    # For `nix run`
    packages.${system}.default = runScript;
  };
}
