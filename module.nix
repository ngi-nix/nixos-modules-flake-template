{ pkgs, ... }: {
  services.nginx.enable = true;
  users.users.root.password = "root";
}
