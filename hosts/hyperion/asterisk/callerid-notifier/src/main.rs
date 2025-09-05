use asterisk_ari::{AriError, apis::channels::models::ChannelState};
use rumqttc::{AsyncClient, Event, MqttOptions};
use serde_json::json;
use std::time::Duration;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    env_logger::init();

    let mut ari = {
        let endpoint = std::env::var("ASTERISK_ENDPOINT")?;
        let username = std::env::var("ASTERISK_USERNAME")?;
        let password = std::env::var("ASTERISK_PASSWORD")?;
        let config = asterisk_ari::Config::new(endpoint, username, password);
        asterisk_ari::AriClient::with_config(config)
    };

    let mqttoptions = {
        let mqtt_host = std::env::var("MQTT_HOST")?;
        let mut opts = MqttOptions::new("callerid-notifier", mqtt_host, 1883);
        opts.set_keep_alive(Duration::from_secs(5));
        opts
    };

    let (mqtt_client, mut mqtt_eventloop) = AsyncClient::new(mqttoptions, 10);

    ari.on_channel_created(move |_, event| {
        let mut mqtt_client_clone = mqtt_client.clone();
        async move {
            log::debug!("event: {event:#?}");
            let chan = event.data.channel;

            if !matches!(chan.state, ChannelState::Ring) {
                return Err(AriError::Internal(
                    "incoming call didn't just start, ignoring".to_string(),
                ));
            }

            if chan.dialplan.context.as_str() != "from-external" {
                return Err(AriError::Internal(
                    "call not from external, ignoring".to_string(),
                ));
            }

            let number = chan.caller.number;
            if number.is_empty() {
                return Err(AriError::Internal(
                    "incoming call has no called id number, ignoring".to_string(),
                ));
            }

            let number = phonenumber::parse(Some(phonenumber::country::HU), number.clone())
                .map(|num| match num.country().id() {
                    Some(phonenumber::country::HU) => {
                        format!("{}", num.format().mode(phonenumber::Mode::National))
                    }
                    Some(country_id) => format!(
                        "({:?}) {}",
                        country_id,
                        num.format().mode(phonenumber::Mode::International)
                    ),
                    None => format!("{}", num.format().mode(phonenumber::Mode::International)),
                })
                .unwrap_or(number);

            log::info!("Incoming call from {number}");

            notify(&mut mqtt_client_clone, number)
                .await
                .inspect_err(|e| log::error!("notify() failed: {e:?}"))
                .ok();

            Ok(())
        }
    });

    ari.start("callerid-notifier").await?;
    log::info!("ARI is up");

    while let Ok(event) = mqtt_eventloop.poll().await {
        handle_mqtt_event(event).await?;
    }

    Ok(())
}

async fn handle_mqtt_event(event: Event) -> anyhow::Result<()> {
    match event {
        other => {
            log::debug!("MQTT event: {other:?}");
        }
    }
    Ok(())
}

async fn notify(mqtt_client: &mut AsyncClient, text: String) -> anyhow::Result<()> {
    let payload = json!({
        "image": "phone_ringing",
        "text": text
    });
    mqtt_client
        .publish(
            "iris/event",
            rumqttc::QoS::ExactlyOnce,
            false,
            payload.to_string(),
        )
        .await?;
    Ok(())
}
