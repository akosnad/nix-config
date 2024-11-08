use qbit_rs::{
    model::{
        Credential, GetTorrentListArg, Hashes, RatioLimit, SeedingTimeLimit,
        SetTorrentSharedLimitArg,
    },
    Qbit,
};
use rumqttc::{AsyncClient, Event, MqttOptions, Packet, QoS};
use serde::Deserialize;
use std::sync::Arc;
use tokio::task;
use tokio_schedule::Job;

#[derive(Debug, Deserialize)]
struct CategoryLimit {
    pub name: String,
    pub seeding_time_limit: isize,
    pub ratio_limit: f64,
}

#[derive(Debug, Deserialize)]
struct Config {
    pub category_limits: Vec<CategoryLimit>,
}

const TOPIC_THROTTLE: &str = "qbt-manager/throttle";

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    env_logger::init();

    let api = {
        let credential = {
            let username = std::env::var("QBITTORRENT_USERNAME")?;
            let password = std::env::var("QBITTORRENT_PASSWORD")?;
            Credential::new(username, password)
        };
        let url = std::env::var("QBITTORRENT_URL")?;
        let url = url.as_str();
        Arc::new(Qbit::new(url, credential))
    };
    log::debug!("successfully authenticated to endpoint");

    let config: Config = {
        let path = std::env::var("QBT_MANAGER_CONFIG")?;
        let path = std::path::Path::new(&path);
        let content = std::fs::read_to_string(path)?;
        serde_yaml::from_str(&content)?
    };
    log::trace!("got config: {:?}", config);

    let api2 = api.clone();
    task::spawn(async move {
        let set_category_limits_schedule = tokio_schedule::every(10).minutes().perform(|| async {
            if let Err(e) = set_category_limits(&config.category_limits, &api2).await {
                log::error!("Failed to set category limits: {e}");
            }
        });
        set_category_limits_schedule.await;
    });

    let mqttoptions = {
        let mqtt_host = std::env::var("MQTT_HOST")?;
        let mut opts = MqttOptions::new("qbt-manager", mqtt_host, 1883);
        opts.set_keep_alive(std::time::Duration::from_secs(5));
        opts
    };

    let (client, mut eventloop) = AsyncClient::new(mqttoptions, 10);
    client.subscribe(TOPIC_THROTTLE, QoS::AtMostOnce).await?;
    log::debug!("subscribed to topic {TOPIC_THROTTLE}");

    while let Ok(event) = eventloop.poll().await {
        handle_mqtt_event(event, &api).await?;
    }
    anyhow::bail!("mqtt eventloop failed");
}

async fn set_category_limits<'a, I>(category_limits: I, api: &Qbit) -> anyhow::Result<()>
where
    I: IntoIterator<Item = &'a CategoryLimit>,
{
    for category in category_limits.into_iter() {
        let category_name = &category.name;
        let torrents = api
            .get_torrent_list(GetTorrentListArg {
                category: Some(category_name.clone()),
                ..Default::default()
            })
            .await?;
        let len = torrents.len();

        log::info!("Setting share limits on category {category_name} for {len} torrents...");

        if torrents.len() == 0 {
            continue;
        }

        let hashes: Hashes = {
            let vec: Vec<String> = torrents.iter().map(|t| t.hash.clone()).flatten().collect();
            Hashes::Hashes(vec.into())
        };
        let ratio_limit_int = category.ratio_limit as isize;
        let ratio_limit = match ratio_limit_int {
            isize::MIN..=0 => RatioLimit::NoLimit,
            _ => RatioLimit::Limited(category.ratio_limit),
        };
        let seeding_time_limit = match category.seeding_time_limit {
            isize::MIN..=0 => SeedingTimeLimit::NoLimit,
            limit => SeedingTimeLimit::Limited(limit as u64),
        };

        log::trace!("\thashes: {:?}", hashes);
        log::info!("\tratio_limit: {ratio_limit:?}, seeding_time_limit: {seeding_time_limit:?}");

        let res = api
            .set_torrent_shared_limit(SetTorrentSharedLimitArg {
                hashes,
                ratio_limit: Some(ratio_limit),
                seeding_time_limit: Some(seeding_time_limit),
                inactive_seeding_time_limit: Some(SeedingTimeLimit::NoLimit),
            })
            .await;
        log::trace!("\tresult: {:?}", res);
        if let Err(e) = res {
            anyhow::bail!(e);
        }
    }

    Ok(())
}

async fn handle_mqtt_event(event: Event, api: &Qbit) -> anyhow::Result<()> {
    match event {
        Event::Incoming(Packet::Publish(p)) => {
            assert!(p.topic == TOPIC_THROTTLE);
            let payload = {
                let string = String::from_iter(p.payload.iter().map(|&b| b as char));
                let Ok(payload): Result<bool, serde_yaml::Error> = serde_yaml::from_str(&string)
                else {
                    anyhow::bail!("Failed to parse payload: {string}");
                };
                log::trace!("Received throttle payload: {}", payload);
                payload
            };
            set_throttling(payload, &api).await?;
        }
        other => {
            log::trace!("Received event: {:?}", other);
        }
    }
    Ok(())
}

async fn set_throttling(do_throttle: bool, api: &Qbit) -> anyhow::Result<()> {
    let throttled = api.get_speed_limits_mode().await?;

    if throttled == do_throttle {
        log::info!("Throttling is already set to {do_throttle}");
        return Ok(());
    }

    log::info!("Setting throttling to {do_throttle}...");
    api.toggle_speed_limits_mode().await?;

    // verify that the change was successful
    let result = api.get_speed_limits_mode().await?;
    if result != do_throttle {
        anyhow::bail!("Failed to set throttling to {do_throttle}");
    }

    Ok(())
}
