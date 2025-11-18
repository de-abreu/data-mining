{pkgs, ...}: {
  packages = with pkgs; [
    dbeaver-bin
    postgresql
    sqlite
  ];

  languages.python = {
    enable = true;
    venv = {
      enable = true;
      requirements = ./requirements.txt;
    };
  };
  services.postgres = {
    enable = true;
    listen_addresses = "127.0.0.1";
    port = 5432;
    extensions = extensions: [
      extensions.age
      extensions.citus
    ];
    initialScript =
      # SQL
      ''
        CREATE ROLE postgres WITH LOGIN SUPERUSER PASSWORD 'postgres';
      '';
  };
}
