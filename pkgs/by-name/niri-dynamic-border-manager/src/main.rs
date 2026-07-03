use bytes::{Buf, BytesMut};
use niri_ipc::{Action, Event, Reply, Request};
use serde::Serialize;
use std::collections::{HashMap, HashSet};
use tokio::{
    io::{AsyncReadExt, AsyncWriteExt},
    net::UnixStream,
};

struct Connection {
    stream: UnixStream,
    buffer: BytesMut,
}
impl Connection {
    fn new(stream: UnixStream) -> Self {
        Self {
            stream,
            buffer: BytesMut::with_capacity(4096),
        }
    }

    pub async fn read_frame(&mut self) -> anyhow::Result<Option<Frame>> {
        loop {
            if let Some(frame) = self.parse_frame()? {
                return Ok(Some(frame));
            }

            if 0 == self.stream.read_buf(&mut self.buffer).await? {
                if self.buffer.is_empty() {
                    return Ok(None);
                } else {
                    anyhow::bail!("Socket was broken");
                }
            }
        }
    }
    pub async fn write_frame(&mut self, frame: &impl Serialize) -> anyhow::Result<()> {
        let raw_frame = {
            let mut r = serde_json::to_vec(frame)?;
            r.push(b'\n');
            r
        };

        if let Ok(s) = str::from_utf8(&raw_frame) {
            eprintln!("writing raw frame: {s}");
        }

        self.stream.write_all(&raw_frame).await?;
        self.stream.flush().await?;
        Ok(())
    }

    fn parse_frame(&mut self) -> anyhow::Result<Option<Frame>> {
        let Some(newline_idx) = self
            .buffer
            .iter()
            .enumerate()
            .find(|(_, b)| **b == b'\n')
            .map(|(idx, _)| idx)
        else {
            return Ok(None);
        };
        let Ok(frame) = serde_json::from_slice::<Frame>(&self.buffer[..newline_idx]) else {
            return Ok(None);
        };
        self.buffer.advance(newline_idx + 1);
        Ok(Some(frame))
    }
}

#[derive(Debug, serde::Deserialize)]
#[serde(untagged)]
enum Frame {
    Event(Event),
    Reply(Reply),
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let sock_path = std::env::var("NIRI_SOCKET")
        .map_err(|e| anyhow::format_err!("getting NIRI_SOCKET env var failed: {}", e))?;
    let event_stream = tokio::net::UnixStream::connect(sock_path.clone())
        .await
        .map_err(|e| anyhow::format_err!("failed to connect to niri socket: {}", e))?;
    let mut event_connection = Connection::new(event_stream);

    event_connection.write_frame(&Request::EventStream).await?;

    let action_stream = tokio::net::UnixStream::connect(sock_path)
        .await
        .map_err(|e| anyhow::format_err!("failed to connect to niri socket: {}", e))?;
    let mut action_connection = Connection::new(action_stream);

    let mut workspace_windows: HashMap<u64, HashSet<u64>> = HashMap::new();
    let mut maximized_windows: HashSet<u64> = HashSet::new();

    macro_rules! update_window {
        ($window:ident) => {
            if !$window.is_floating
                && let Some(workspace_id) = $window.workspace_id
            {
                if let Some(windows) = workspace_windows.get_mut(&workspace_id) {
                    windows.insert($window.id);
                } else {
                    let windows = {
                        let mut set = HashSet::new();
                        set.insert($window.id);
                        set
                    };
                    workspace_windows.insert(workspace_id, windows);
                }
            }
        };
    }

    while let Some(frame) = event_connection.read_frame().await? {
        match frame {
            Frame::Event(Event::WindowsChanged { windows }) => {
                workspace_windows.clear();
                for window in windows.iter() {
                    update_window!(window);
                }
                eprintln!(
                    "windows_changed, workspace_windows: {workspace_windows:?}, maximized_windows: {maximized_windows:?}"
                );
            }
            Frame::Event(Event::WindowOpenedOrChanged { window }) => {
                for (_, windows) in workspace_windows.iter_mut() {
                    windows.remove(&window.id);
                }
                update_window!(window);
                let id = window.id;
                eprintln!(
                    "window_opened_or_changed: {id}, workspace_windows: {workspace_windows:?}, maximized_windows: {maximized_windows:?}"
                );
            }
            Frame::Event(Event::WindowClosed { id }) => {
                for (_, windows) in workspace_windows.iter_mut() {
                    windows.remove(&id);
                }
                maximized_windows.remove(&id);
                eprintln!(
                    "window_closed: {id}, workspace_windows: {workspace_windows:?}, maximized_windows: {maximized_windows:?}"
                );
            }
            Frame::Reply(reply) => {
                eprintln!("reply: {reply:?}");
            }
            _ => {}
        }

        for (_, windows) in workspace_windows.iter() {
            if windows.len() == 1 {
                let window_id: &u64 = windows
                    .into_iter()
                    .next()
                    .expect("where `windows.len() == 1` holds, we should have at least one window");
                if !maximized_windows.contains(window_id) {
                    action_connection
                        .write_frame(&Request::Action(Action::MaximizeWindowToEdges {
                            id: Some(*window_id),
                        }))
                        .await?;
                    maximized_windows.insert(*window_id);
                    eprintln!("maximized {window_id}");
                }
            } else {
                for window_id in windows.iter() {
                    if maximized_windows.contains(window_id) {
                        action_connection
                            .write_frame(&Request::Action(Action::MaximizeWindowToEdges {
                                id: Some(*window_id),
                            }))
                            .await?;
                        maximized_windows.remove(window_id);
                        eprintln!("un-maximized {window_id}");
                    }
                }
            }
        }
    }

    anyhow::bail!("connection was closed")
}
