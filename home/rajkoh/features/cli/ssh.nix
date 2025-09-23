{
  # programs.ssh = {
  #   enable = true;
  # };

  home.persistence = {
    "/persist/home/rajkoh".directories = [".ssh"];
  };
}
