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
        jupyter
        jupysql
        lsprotocol
        matplotlib
        pandas
        pandas-stubs
        plotly
        psycopg2
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
  in {
    # For `nix develop`
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [pythonEnv] ++ dependencies;
    };
  };
}
