{
  services.home-assistant.additionalDashboards.akos = {
    title = "Ákos";
    views = [{
      title = "example";
      cards = [{
        type = "markdown";
        title = "Dashboard";
        content = "hello **world**!";
      }];
    }];
  };
}
