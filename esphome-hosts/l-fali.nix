{ common, ... }:
{
  settings = common.athom-15w-bulb
    {
      icon = "mdi:ceiling-light";
    } // {
    esphome.friendly_name = "Nagyszoba fali lámpa";
  };
}
