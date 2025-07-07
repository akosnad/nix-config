{ common, ... }:
{
  settings = common.athom-15w-bulb
    {
      icon = "mdi:floor-lamp-torchiere";
    } // {
    esphome.friendly_name = "Ákos állólámpa";
  };
}
