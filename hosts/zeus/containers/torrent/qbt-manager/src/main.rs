use qbit_rs::{Qbit, model::{Credential, GetTorrentListArg, SetTorrentSharedLimitArg, Hashes, RatioLimit, SeedingTimeLimit}};
use serde::Deserialize;
use tokio_schedule::Job;

#[derive(Debug, Deserialize)]
struct CategoryLimit {
    pub name: String,
    pub seeding_time_limit: isize,
    pub ratio_limit: f64
}


#[derive(Debug, Deserialize)]
struct Config {
    pub category_limits: Vec<CategoryLimit>,
}


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
        Qbit::new(url, credential)
    };
    log::debug!("successfully authenticated to endpoint");

    let config: Config = {
        let path = std::env::var("QBT_MANAGER_CONFIG")?;
        let path = std::path::Path::new(&path);
        let content = std::fs::read_to_string(path)?;
        serde_yaml::from_str(&content)?
    };
    log::trace!("got config: {:?}", config);

    let set_category_limits_schedule = tokio_schedule::every(1).minutes().perform(|| async {
        if let Err(e) = set_category_limits(&config.category_limits, &api).await {
            log::error!("Failed to set category limits: {e}");
        }
    });
    set_category_limits_schedule.await;

    // TODO: throttling management

    Ok(())
}

async fn set_category_limits<'a, I>(category_limits: I, api: &Qbit) -> anyhow::Result<()>
where
    I: IntoIterator<Item = &'a CategoryLimit>
{
    for category in category_limits.into_iter() {
        let category_name = &category.name;
        let torrents = api.get_torrent_list(GetTorrentListArg {
            category: Some(category_name.clone()),
            ..Default::default()
        }).await?;
        let len = torrents.len();

        log::info!("Setting share limits on category {category_name} for {len} torrents...");

        if torrents.len() == 0 {
            continue;
        }

        let hashes: Hashes = {
            let vec: Vec<String> = torrents
                .iter()
                .map(|t| t.hash.clone())
                .flatten()
                .collect();
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

        let res = api.set_torrent_shared_limit(SetTorrentSharedLimitArg {
            hashes, 
            ratio_limit: Some(ratio_limit),
            seeding_time_limit: Some(seeding_time_limit),
            inactive_seeding_time_limit: Some(SeedingTimeLimit::NoLimit),
        }).await;
        log::trace!("\tresult: {:?}", res);
        if let Err(e) = res {
            anyhow::bail!(e);
        }
    }

    Ok(())
}
