use rumqttc::v5::{
    AsyncClient, Event, MqttOptions,
    mqttbytes::{QoS, v5::Packet},
};
use serde_json::Value;
use std::{collections::HashMap, env, path::PathBuf, time::Duration};
use tokio::{
    io::{AsyncBufReadExt, BufReader},
    time::sleep,
};

struct UserApiKeys {
    map: HashMap<String, String>,
}
impl UserApiKeys {
    pub async fn from_file(path: PathBuf) -> anyhow::Result<Self> {
        let file = tokio::fs::File::open(path).await?;
        let reader = BufReader::new(file);
        let mut lines = reader.lines();

        let mut map = HashMap::new();

        while let Some(line) = lines.next_line().await? {
            let line = line.trim();
            if line.is_empty() || line.starts_with('#') {
                continue;
            }
            if let Some((user, api_key)) = line.split_once(':') {
                map.insert(user.trim().to_string(), api_key.trim().to_string());
            }
        }

        Ok(Self { map })
    }
    pub fn get_api_key(&self, user: String) -> anyhow::Result<&String> {
        self.map
            .get(&user)
            .ok_or(anyhow::format_err!("User with no API key provided"))
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenv::dotenv().ok();
    env_logger::init();

    let user_api_keys = {
        let path_raw = env::var("USER_APIKEY_MAPPING_FILE")?;
        let path = PathBuf::try_from(path_raw)?;
        UserApiKeys::from_file(path).await?
    };

    let broker_host = env::var("BROKER_HOST")?;
    let broker_port = {
        let raw = env::var("BROKER_PORT")?;
        let port = raw.parse()?;
        port
    };
    let opts = {
        let mut opts = MqttOptions::new("owntracks-to-dawarich", broker_host.clone(), broker_port);
        opts.set_keep_alive(Duration::from_secs(10));
        opts.set_clean_start(false);
        opts
    };
    log::debug!("Using MQTT connection options: {opts:?}");
    log::info!("Using MQTT broker: {broker_host}:{broker_port}");

    let subscribe_topic = env::var("SUBSCRIBE_TOPIC")?;
    log::info!("Using MQTT topic: {subscribe_topic}");
    let (mqtt, mut eventloop) = AsyncClient::new(opts, 10);
    if let Err(e) = mqtt
        .subscribe(subscribe_topic.clone(), QoS::AtLeastOnce)
        .await
    {
        anyhow::bail!("failed to subscribe to topic {subscribe_topic}: {e:?}");
    }

    let url = {
        let base = env::var("DAWARICH_URL")?;
        format!("{base}/api/v1/owntracks/points")
    };
    log::info!("Using API endpoint: {url}");
    let client = reqwest::Client::new();

    loop {
        let event = eventloop.poll().await.expect("mqtt poll failed");
        if let Event::Incoming(Packet::Publish(p)) = event {
            let topic = String::from_utf8_lossy(&p.topic);
            let payload = String::from_utf8_lossy(&p.payload);

            let topic_parts = topic.split('/').collect::<Vec<&str>>();
            match &topic_parts[..] {
                [_, user, device] => {
                    log::info!(
                        "Received message from device {device} belonging to user {user} with payload: {payload}"
                    );
                    match serde_json::from_str::<Value>(&payload) {
                        Ok(val) if val.is_object() => {
                            let url_with_token = {
                                let token = match user_api_keys.get_api_key(user.to_string()) {
                                    Ok(key) => key,
                                    Err(e) => {
                                        log::error!("{e}");
                                        continue;
                                    }
                                };
                                format!("{url}?api_key={token}")
                            };
                            log::debug!("parsed payload: {val:?}");
                            loop {
                                let res = client
                                    .post(url_with_token.clone())
                                    .body(val.to_string())
                                    .header("Content-Type", "application/json; charset=utf-8")
                                    .send()
                                    .await;
                                match res {
                                    Ok(r) if r.status().is_success() => {
                                        log::info!("message accepted");
                                        break;
                                    }
                                    _ => {
                                        log::error!("failed to post message, retrying ...");
                                        sleep(Duration::from_secs(2)).await;
                                    }
                                }
                            }
                        }
                        Ok(val) => {
                            log::error!("invalid payload received: {}", val.to_string());
                        }
                        Err(e) => {
                            log::error!(
                                "failed to parse payload with error {e:?}, payload: {payload}"
                            );
                        }
                    }
                }
                _ => {
                    log::error!("failed to parse topic {topic}, ignoring message");
                    continue;
                }
            }
        }
    }
}
