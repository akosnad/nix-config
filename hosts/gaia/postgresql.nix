{
  services.postgresql = {
    enable = true;
    settings = {
      max_connections = "300";
      shared_buffers = "80MB";
    };
  };
}
