{
  services.home-assistant.config.template = {
    sensor = [
      {
        name = "Internet down speed";
        icon = "mdi:download";
        unit_of_measurement = "Mbit/s";
        state = "{{ ((states('sensor.nodered_6f48524732add6e7') | float) / 1024 / 1024 * 8) | round(1) }}";
        state_class = "measurement";
      }
      {
        name = "Internet up speed";
        icon = "mdi:upload";
        unit_of_measurement = "Mbit/s";
        state = "{{ ((states('sensor.nodered_ab9d753af576d821') | float) / 1024 / 1024 * 8) | round(1) }}";
        state_class = "measurement";
      }
      {
        name = "Outside max illuminance";
        unit_of_measurement = "lx";
        state = /* jinja2 */ ''
          {% set ns = namespace (max = -1, found = false) %}
          {% set sensors = [states('sensor.outside_illuminance'), states('sensor.outside_front_illuminance')] %}
          
          {% for s in sensors %}
            {% if s != 'unavailable' and s != 'unknown' %}
              {% if s | float > ns.max %}
                {% set ns.max = (s | float) %}
                {% set ns.found = true %}
              {% endif %}
            {% endif %}
          {% endfor %}
          
          {% if not ns.found %}
            unknown
          {% else -%}
            {{ ns.max | round(2) }}
          {% endif %}
        '';
        icon = "mdi:brightness-5";
      }
      {
        name = "Outside min temperature";
        unit_of_measurement = "°C";
        state = /* jinja2 */ ''
          {% set ns = namespace (min = 9999, found = false) %}
          {% set sensors = [states('sensor.outside_temperature'), states('sensor.outside_front_temperature')] %}
          
          {% for s in sensors %}
            {% if s != 'unavailable' and s != 'unknown' %}
              {% if s | float < ns.min %}
                {% set ns.min = (s | float) %}
                {% set ns.found = true %}
              {% endif %}
            {% endif %}
          {% endfor %}
          
          {% if not ns.found %}
            unknown
          {% else -%}
            {{ ns.min | round(2) }}
          {% endif %}
        '';
        icon = "mdi:thermometer";
      }
      {
        name = "Outside average pressure";
        unit_of_measurement = "hPa";
        state = /* jinja2 */ ''
          {% set ns = namespace (sum = 0, n = 0) %}
          {% set sensors = [states('sensor.outside_pressure'), states('sensor.outside_front_pressure')] %}
          
          {% for s in  sensors %}
            {% if s != 'unavailable' and s != 'unknown' %}
              {% set ns.sum = ns.sum + (s | float) %}
              {% set ns.n = ns.n + 1 %}
            {% endif %}
          {% endfor %}
          
          {% if ns.n == 0 %}
            unknown
          {% else -%}
            {{ (ns.sum / ns.n) | round(3) }}
          {% endif %}
        '';
        icon = "mdi:gauge";
      }
      {
        name = "Outside average humidity";
        unit_of_measurement = "%";
        state = /* jinja2 */ ''
          {% set ns = namespace (sum = 0, n = 0) %}
          {% set sensors = [states('sensor.outside_humidity'), states('sensor.outside_front_humidity')] %}
          
          {% for s in  sensors %}
            {% if s != 'unavailable' and s != 'unknown' %}
              {% set ns.sum = ns.sum + (s | float) %}
              {% set ns.n = ns.n + 1 %}
            {% endif %}
          {% endfor %}
          
          {% if ns.n == 0 %}
            unknown
          {% else -%}
            {{ (ns.sum / ns.n) | round(3) }}
          {% endif %}
        '';
        icon = "mdi:water-percent";
      }
      {
        name = "Gate door";
        state = /* jinja2 */ ''
          {{ "unavailable" if states('sensor.gate_door_distance') == "unavailable"
            else "zárva" if states('sensor.gate_door_distance') == "unknown"
            else "zárva" if ((states('sensor.gate_door_distance') | float) > 1.55) or (states('sensor.gate_door_distance') | float) < 0.19
            else "félig nyitva" if (states('sensor.gate_door_distance') | float) > 0.5
            else "nyitva"
          }}
        '';
        icon = /* jinja2 */ ''
          {{ 'hass:gate' if states('sensor.gate_door_distance') == "unknown"
            else 'hass:gate' if ((states('sensor.gate_door_distance') | float) > 1.55) or (states('sensor.gate_door_distance') | float) < 0.19
            else 'hass:gate-alert' if (states('sensor.gate_door_distance') | float) > 0.5
            else 'hass:gate-open'
          }}
        '';
      }
      {
        name = "Humidifier control";
        state = /* jinja2 */ ''
          {{'turn_off' if (states('sensor.inside_humidity') | float) > 52.0 else
            'turn_on' if (states('sensor.inside_humidity') | float) < 48.0 else
            'stay'
          }}
        '';
      }
      {
        name = "Vili tracker power";
        unit_of_measurement = "W";
        icon = "mdi:lightning-bolt";
        state = /* jinja2 */ ''
          {{ (states('sensor.vili_voltage') | float) * (states('sensor.vili_current') | float) }}
        '';
      }
      {
        name = "Akos next alarm";
        icon = "mdi:alarm";
        device_class = "timestamp";
        state = /* jinja2 */ ''
          {% set n = as_timestamp(now()) %}
          {% set dst_offset = now().timetuple().tm_isdst * 3600 %}
          {% set offset = (as_timestamp(n | timestamp_custom("%Y-%m-%dT%H:%M:%S+00:00")) - n) | round(0, 'ceil') %}
          {% set offset_fix = offset - dst_offset %}
          {% set format_fix = "%Y-%m-%dT%H:%M:%S+" + "%02.f:00" | format(offset_fix / 60 / 60) %}
          {% set format = "%Y-%m-%dT%H:%M:%S+" + "%02.f:00" | format(offset / 60 / 60) %}
          
          {% set t = states.sensor.hermes_next_alarm.state %}
          {% set t_fix = as_timestamp(as_timestamp(t) | timestamp_custom(format_fix)) %}
          {# t_fix | timestamp_custom(format) #}

          {{(as_timestamp(t) + offset) | timestamp_custom(format)}}
        '';
      }
    ];
  };
}
