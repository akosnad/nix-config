{ ... }:
{
  virtualisation.docker = {
    enable = true;
  };

  virtualisation.oci-containers.backend = "docker";

  environment.persistence."/persist".directories = [ "/var/lib/docker" ];
}
