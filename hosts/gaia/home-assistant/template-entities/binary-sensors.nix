{
  services.home-assistant.config.binary_sensor = [{
    platform = "template";
    sensors = {
      nobody_home = {
        friendly_name = "Mindenki távol";
        value_template = /* jinja */ ''
          {{ not (is_state('person.kazi', 'home')) and not (is_state('person.ani', 'home')) and not (is_state('person.nadudvari_akos', 'home')) }}
        '';
      };
      is_dark = {
        friendly_name = "Sötét van";
        value_template = /* jinja */ ''
          {{ states('sensor.outside_max_illuminance')|float <= states('input_number.darkness_threshold')|float }}
        '';
        icon_template = /* jinja */ ''
          {{ 'hass:weather-night' if now().hour >= 20
            else 'hass:weather-cloudy' if states('binary_sensor.is_dark') == true
            else 'hass:weather-sunny'
          }}
        '';
      };
      humidifier_state = {
        friendly_name = "Párásító";
        value_template = /* jinja */ ''
          {{ states('humidifier.deerma_jsq5_8632_humidifier') == 'on' }}
        '';
      };
      home_internet = {
        friendly_name = "Otthoni internet";
        device_class = "connectivity";
        value_template = /* jinja */ ''
          {%- set wan = states('binary_sensor.wan_link') == 'on' %}
          {%- set wan6 = states('binary_sensor.wan6_link') == 'on' %}
          {{- wan or wan6 }}
        '';
      };
      metered_internet = {
        friendly_name = "Mobilinternet";
        device_class = "connectivity";
        value_template = /* jinja */ ''
          {% set wan = states('binary_sensor.wan_link') == 'on' %}
            {% set wan6 = states('binary_sensor.wan6_link') == 'on' %}
            {% set wwan = states('binary_sensor.wwan_link') == 'on' %}
            {% set wwan6 = states('binary_sensor.wwan6_link') == 'on' %}
            {% set usbwan = states('binary_sensor.usbwan_link') == 'on' %}
            {% set usbwan6 = states('binary_sensor.wan6_link') == 'on' %}
            
            {%- if not wan and not wan6 %}
              {{- wwan or wwan6
                or usbwan or usbwan6
              }}
            {%- else %}
              {{ false }}
            {%- endif %}
        '';
      };
    };
  }];
}
