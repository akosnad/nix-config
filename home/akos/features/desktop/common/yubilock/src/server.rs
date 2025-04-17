use serde::{Deserialize, Serialize};
use std::{collections::HashSet, io::Result, path::Path, str::FromStr, sync::Arc};
use tokio::{
    io::{AsyncReadExt, AsyncWriteExt},
    net::{
        unix::{OwnedReadHalf, OwnedWriteHalf},
        UnixListener,
    },
    select,
    sync::{
        mpsc::{self, UnboundedReceiver, UnboundedSender},
        Mutex,
    },
    time::Instant,
};

#[derive(Clone, Debug)]
struct Client {
    id: Instant,
    inner: Arc<Mutex<OwnedWriteHalf>>,
}

impl Client {
    fn new(inner: OwnedWriteHalf) -> Self {
        Self {
            id: Instant::now(),
            inner: Arc::new(Mutex::new(inner)),
        }
    }
}

impl std::hash::Hash for Client {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.id.hash(state);
    }
}

impl PartialEq for Client {
    fn eq(&self, other: &Self) -> bool {
        self.id.eq(&other.id)
    }
}
impl Eq for Client {}

#[derive(Debug, Clone)]
pub(crate) enum Event {
    Connected,
    Disconnected,
    Locked,
    Unlocked,
    LockToggled,
}

impl From<Command> for Event {
    fn from(value: Command) -> Self {
        match value {
            Command::Lock => Event::Locked,
            Command::Unlock => Event::Unlocked,
            Command::Toggle => Event::LockToggled,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
struct State {
    locked: bool,
    // FIXME: support handling multiple yubikeys being plugged in/out
    connected: bool,
}

impl State {
    fn new(locked: bool, connected: bool) -> Self {
        Self { locked, connected }
    }

    fn as_waybar_module(&self) -> String {
        let locked = if self.locked { "locked" } else { "unlocked" };
        let connected = if self.connected {
            "connected"
        } else {
            "disconnected"
        };
        let text = format!("Yubilock {locked} and Yubikey {connected}");

        let json = serde_json::json!({
            "text": text,
            "tooltip": text,
            "alt": if self.locked { "active" } else { "inactive" },
            "class": format!("yubilock-{locked}-{connected}"),
        })
        .to_string();

        format!("{json}\n")
    }

    fn handle_event(&mut self, event: Event) {
        match event {
            Event::Disconnected if self.locked && self.connected => {
                self.connected = false;
                handle_locked_disconnect();
            }
            Event::Disconnected => self.connected = false,
            Event::Connected => self.connected = true,
            Event::Locked => self.locked = true,
            Event::Unlocked => self.locked = false,
            Event::LockToggled => self.locked = !self.locked,
        }
    }
}

pub(crate) struct Server {
    listener: Option<UnixListener>,
    clients: Arc<Mutex<HashSet<Client>>>,
    event_rx: Option<UnboundedReceiver<Event>>,
    event_tx: UnboundedSender<Event>,
    state: State,
}
impl Server {
    pub fn new<P: AsRef<Path>>(
        socket_path: P,
        initial_connected_count: usize,
        event_rx: UnboundedReceiver<Event>,
        event_tx: UnboundedSender<Event>,
    ) -> Result<Self> {
        Ok(Self {
            listener: Some(UnixListener::bind(socket_path)?),
            clients: Default::default(),
            event_rx: Some(event_rx),
            event_tx: event_tx.clone(),
            state: State::new(true, initial_connected_count != 0),
        })
    }

    pub async fn run(&mut self) -> anyhow::Result<()> {
        let Some(mut rx) = self.event_rx.take() else {
            anyhow::bail!("Server already running, refusing consequent call to run())");
        };
        let Some(listener) = self.listener.take() else {
            anyhow::bail!("Server already running, refusing consequent call to run())");
        };

        let clients_accept = self.clients.clone();
        let clients_event_tx = self.event_tx.clone();

        let (client_connected_tx, mut client_connected_rx) = mpsc::unbounded_channel();
        tokio::spawn(async move {
            loop {
                match listener.accept().await {
                    Ok((stream, _addr)) => {
                        let (read_half, write_half) = stream.into_split();
                        tokio::spawn(read_client(read_half, clients_event_tx.clone()));
                        let client = Client::new(write_half);
                        let _ = client_connected_tx.send(client.clone());
                        clients_accept.lock().await.insert(client);
                    }
                    Err(_) => continue,
                }
            }
        });

        loop {
            select! {
                event = rx.recv() => {
                    if let Some(event) = event {
                        self.handle_event(event).await;
                    } else {
                        anyhow::bail!("event_rx closed");
                    }
                }
                client = client_connected_rx.recv() => {
                    if let Some(client) = client {
                        let mut client = client.inner.lock().await;
                        let _ = self.handle_initial_state(&mut client).await;
                    } else {
                        anyhow::bail!("client_connected_rx closed");
                    }
                }
            }
        }
    }

    async fn handle_initial_state(&self, client: &mut OwnedWriteHalf) -> anyhow::Result<()> {
        let s = self.state.as_waybar_module();
        client.write_all(s.as_bytes()).await?;
        Ok(())
    }

    async fn handle_event(&mut self, event: Event) {
        let old_state = self.state;
        self.state.handle_event(event);
        if self.state != old_state {
            self.broadcast_state().await;
        }
    }

    async fn broadcast_state(&mut self) {
        let s = self.state.as_waybar_module();
        let mut clients = self.clients.lock().await;
        let mut disconnected = Vec::new();

        for client in clients.iter() {
            if client
                .inner
                .lock()
                .await
                .write_all(s.as_bytes())
                .await
                .is_err()
            {
                disconnected.push(client.clone());
            }
        }

        for client in disconnected {
            clients.remove(&client);
        }
    }
}

#[derive(Deserialize)]
enum Command {
    Lock,
    Unlock,
    Toggle,
}
impl FromStr for Command {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        match s {
            "lock\n" => Ok(Self::Lock),
            "unlock\n" => Ok(Self::Unlock),
            "toggle\n" => Ok(Self::Toggle),
            _ => anyhow::bail!("invalid command"),
        }
    }
}

async fn read_client(
    mut read_half: OwnedReadHalf,
    events_tx: UnboundedSender<Event>,
) -> anyhow::Result<()> {
    let mut buf = String::new();
    let len = read_half.read_to_string(&mut buf).await?;
    let cmd = Command::from_str(&buf[..len])?;
    events_tx.send(cmd.into())?;
    Ok(())
}

fn handle_locked_disconnect() {
    match std::process::Command::new("hyprlock")
        .args(["--immediate"])
        .spawn()
    {
        Ok(child) => println!("spawned child: {child:?}"),
        Err(e) => eprintln!("failed to spawn child: {e:?}"),
    }
}
