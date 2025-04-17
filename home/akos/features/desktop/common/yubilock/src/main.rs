use rusb::{Hotplug, HotplugBuilder, UsbContext};
use tokio::sync::mpsc::{self, UnboundedSender};

mod server;
use server::Event;

const YUBICO_VENDOR_ID: u16 = 0x1050;

struct HotplugWatcher {
    event_tx: UnboundedSender<Event>,
}

impl HotplugWatcher {
    fn new(event_tx: UnboundedSender<Event>) -> anyhow::Result<Self> {
        Ok(Self { event_tx })
    }
}

impl<C: UsbContext> Hotplug<C> for HotplugWatcher {
    fn device_arrived(&mut self, device: rusb::Device<C>) {
        println!("connected: {device:?}");
        let _ = self.event_tx.send(Event::Connected);
    }

    fn device_left(&mut self, device: rusb::Device<C>) {
        println!("disconnected: {device:?}");
        let _ = self.event_tx.send(Event::Disconnected);
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let runtime_dir = std::env::var("XDG_RUNTIME_DIR").expect("XDG_RUNTIME_DIR not set");
    let sock_path = format!("{runtime_dir}/yubilock.sock");

    if std::path::Path::new(&sock_path).exists() {
        std::fs::remove_file(sock_path.clone()).expect("can't remove existing socket file");
    }

    let (event_tx, event_rx) = mpsc::unbounded_channel();

    let usb_context = rusb::Context::new()?;
    let connected_count = usb_context
        .devices()?
        .iter()
        .flat_map(|d| d.device_descriptor().map(|desc| desc.vendor_id()).ok())
        .filter(|vid| *vid == YUBICO_VENDOR_ID)
        .count();

    let mut server = server::Server::new(sock_path, connected_count, event_rx, event_tx.clone())?;
    tokio::spawn(async move {
        if let Err(e) = server.run().await {
            panic!("socket server failed to run: {e:?}");
        }
    });

    let hotplug_watcher = Box::new(HotplugWatcher::new(event_tx.clone())?);
    let hotplug_registration = HotplugBuilder::new()
        .vendor_id(YUBICO_VENDOR_ID)
        .register(usb_context.clone(), hotplug_watcher)?;
    loop {
        if let Err(e) = usb_context.handle_events(None) {
            // keep the hotplug events alive "forever" by not dropping until now
            let _ = hotplug_registration;

            anyhow::bail!("failed to handle USB events: {e:?}");
        }
    }
}
