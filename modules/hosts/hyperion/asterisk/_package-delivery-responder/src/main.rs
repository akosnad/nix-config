use std::{net::SocketAddr, str::FromStr, sync::Arc};

use asterisk_ari::{
    AriError,
    apis::{
        bridges::params::AddChannelRequest,
        channels::params::{DeleteRequest, ExternalMediaRequest, Transport},
    },
};
use async_openai::types::realtime::{
    ConversationItemCreateEvent, Item, ResponseCreateEvent, ServerEvent,
};
use audio_codec_algorithms::{decode_ulaw, encode_ulaw};
use futures_channel::mpsc::{UnboundedReceiver, UnboundedSender};
use futures_util::{
    StreamExt as _, future,
    lock::Mutex,
    pin_mut,
    stream::{Next, SplitStream},
};
use itertools::Itertools;
use rtp::{codecs::g7xx::G711Payloader, packetizer::Packetizer, sequence::new_fixed_sequencer};
use tokio::{
    io::{AsyncReadExt, AsyncWriteExt},
    net::UdpSocket,
};
use tokio_tungstenite::{
    connect_async,
    tungstenite::{client::IntoClientRequest as _, protocol::Message},
};
use tokio_util::{
    bytes::{Buf, Bytes, BytesMut},
    codec::{self, BytesCodec},
    udp::UdpFramed,
};

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

    let ids = Arc::new(Mutex::new(None));

    let (rtp_tx, mut rtp_rx) = futures_channel::mpsc::unbounded();
    let _rtp_tx = rtp_tx.clone();
    let _ids = ids.clone();
    ari.on_stasis_start(move |client, event| {
        let rtp_tx = _rtp_tx.clone();
        let ids = _ids.clone();
        async move {
            log::debug!("StasisStart: {event:?}");
            if event.data.channel.name.starts_with("UnicastRTP") {
                // in newly created external media channel
            } else {
                log::info!("Received new call: {}", event.data.channel.id);

                client.channels().answer(&event.data.channel.id).await?;
                log::trace!("user channel answered");
                // client.channels().play(asterisk_ari::apis::channels::params::PlayRequest::new(&event.data.channel.id, "sound:tt-weasels")).await?;

                let rtp_sock = tokio::net::UdpSocket::bind("0.0.0.0:0").await.unwrap();
                let local_socket_addr = rtp_sock.local_addr().unwrap();
                log::debug!("Local RTP socket bound to: {local_socket_addr}");

                let ext_media = client
                    .channels()
                    .external_media(ExternalMediaRequest::new(
                        "pd_bot",
                        format!("100.64.0.1:{}", local_socket_addr.port()),
                        "ulaw",
                    ))
                    .await
                    .inspect_err(|e| {
                        log::error!("external media channel creation failed: {e:?}")
                    })?;
                log::debug!("extnernal media channel created: {ext_media:?}");

                let rtp_endpoint = ext_media
                    .channel_vars
                    .and_then(|vars| {
                        Some((
                            vars.get("UNICASTRTP_LOCAL_ADDRESS").cloned(),
                            vars.get("UNICASTRTP_LOCAL_PORT").cloned(),
                        ))
                    })
                    .and_then(|v| match v {
                        (
                            Some(serde_json::Value::String(ip)),
                            Some(serde_json::Value::String(port)),
                        ) => Some((ip, port)),
                        _ => None,
                    })
                    .and_then(|(ip, port)| match port.parse::<u16>() {
                        Ok(port) => Some((ip, port)),
                        Err(_) => None,
                    });
                let Some((ip, port)) = rtp_endpoint else {
                    return Err(AriError::Internal(
                        "external media channel has no local ip and/or port specified".to_string(),
                    ));
                };
                let Ok(remote_socket_addr) = SocketAddr::from_str(format!("{ip}:{port}").as_str())
                else {
                    return Err(AriError::Internal(
                        "external media channel ip/port parse failed".to_string(),
                    ));
                };

                let (bridge_tx, bridge_rx) = futures_channel::mpsc::unbounded::<Vec<u8>>();
                tokio::spawn(async move {
                    // if let Err(e) = rtp_sock.connect(remote_socket_addr).await {
                    //     log::error!("failed to connect rtp socket: {e:?}");
                    //     std::process::exit(1);
                    // }
                    let rtp_sock = Arc::new(rtp_sock);
                    let bridge_to_rtp =
                        bridge_to_rtp(bridge_rx, rtp_sock.clone(), remote_socket_addr);
                    let rtp_to_bridge = rtp_to_bridge(rtp_tx, rtp_sock.clone(), remote_socket_addr);

                    pin_mut!(bridge_to_rtp, rtp_to_bridge);
                    future::select(bridge_to_rtp, rtp_to_bridge).await;
                });

                let bridge = client.bridges().create(Default::default()).await?;
                log::debug!("bridge created: {bridge:?}");
                ids.lock_owned()
                    .await
                    .replace((bridge.id.clone(), ext_media.id.clone()));
                client
                    .bridges()
                    .add_channel(AddChannelRequest::new(&bridge.id, ext_media.id).with_role("bot"))
                    .await?;
                log::trace!("bot channel added to bridge");
                client
                    .bridges()
                    .add_channel(
                        AddChannelRequest::new(&bridge.id, &event.data.channel.id)
                            .with_role("user"),
                    )
                    .await?;
                log::trace!("user channel added to bridge");

                // let test = tokio::fs::read("./test.raw").await.unwrap();
                // log::debug!("test data read: {}B", test.len());
                // bridge_tx.unbounded_send(test).unwrap();
            }

            log::trace!("stasis start handler done");
            Ok(())
        }
    });

    let _rtp_tx = rtp_tx.clone();
    let _ids = ids.clone();
    ari.on_stasis_end(move |client, event| {
        let rtp_tx = rtp_tx.clone();
        let ids = _ids.clone();
        async move {
            log::info!("Call ended: {}", event.data.channel.id);
            rtp_tx.close_channel();
            let mut ids = ids.lock_owned().await;
            if let Some((bridge_id, ext_media_chan_id)) = ids.take() {
                client
                    .channels()
                    .delete(DeleteRequest::new(ext_media_chan_id))
                    .await?;
                client.bridges().delete(bridge_id).await?;
            }
            Ok(())
        }
    });

    log::info!("Asterisk is up: {:?}", ari.asterisk().ping().await?);

    let mut _ari = ari.clone();
    tokio::spawn(async move {
        _ari.start("pd_bot".to_string()).await.unwrap();
    });

    // let (stdin_tx, stdin_rx) = futures_channel::mpsc::unbounded();
    // tokio::spawn(call_audio_to_ai(stdin_tx));

    // let realtime_url = "wss://api.openai.com/v1/realtime?model=gpt-realtime";
    // let openai_api_key = std::env::var("OPENAI_API_KEY")?;

    // let mut request = realtime_url.into_client_request()?;
    // request.headers_mut().insert(
    //     "Authorization",
    //     format!("Bearer {openai_api_key}").parse()?
    // );

    // let (ws_stream, _) = connect_async(request).await?;
    // log::info!("OpenAI websocket is up");

    // let (write, read) = ws_stream.split();

    // let stdin_to_ws = stdin_rx.map(Ok).forward(write);

    // let ws_to_log = {
    //     read.for_each(|message| async {
    //         let message = message.unwrap();

    //         match message {
    //             Message::Text(_) => {
    //                 let data = message.clone().into_data();
    //                 let server_event: Result<ServerEvent, _> = serde_json::from_slice(&data);
    //                 match server_event {
    //                     Ok(server_event) => {
    //                         let value = serde_json::to_value(&server_event).unwrap();
    //                         let event_type = value["type"].clone();

    //                         eprint!("{:32} | ", event_type.as_str().unwrap());

    //                         match server_event {
    //                             ServerEvent::ResponseOutputItemDone(event) => {
    //                                 event.item.content.unwrap_or(vec![]).iter().for_each(|c| {
    //                                     if let Some(ref transcript) = c.transcript {
    //                                         eprintln!("[{:?}]: {}", event.item.role, transcript.trim());
    //                                     }
    //                                 });
    //                             }
    //                             ServerEvent::ResponseAudioTranscriptDelta(event) => {
    //                                 eprint!("{}", event.delta.trim());
    //                             }
    //                             ServerEvent::Error(e) => {
    //                                 eprint!("{e:?}");
    //                             }
    //                             _ => {}
    //                         }
    //                     },
    //                     Err(e) => {
    //                         log::error!("failed to deserialize event: {e:?}");
    //                         log::error!("{message:?}");
    //                     }
    //                 }
    //             },
    //             Message::Binary(_) => eprintln!("bytes"),
    //             Message::Ping(_) => eprintln!("bytes"),
    //             Message::Pong(_) => eprintln!("bytes"),
    //             Message::Frame(_) => eprintln!("frame"),
    //             Message::Close(_) => {
    //                 log::info!("Realtime session close");
    //             },
    //         }

    //         eprint!("\n");
    //     })
    // };

    // pin_mut!(stdin_to_ws, ws_to_log);
    // futures_util::future::select(stdin_to_ws, ws_to_log).await;

    let mut file = tokio::fs::File::create("./phone.raw").await?;
    while let Some(d) = rtp_rx.next().await {
        file.write(&d).await?;
        log::trace!("rtp recv: {} samples", d.len());
    }
    // wait for cleanup
    tokio::time::sleep(std::time::Duration::from_secs(5)).await;
    Ok(())
}

async fn bridge_to_rtp(
    mut bridge_rx: UnboundedReceiver<Vec<u8>>,
    rtp_sock: Arc<UdpSocket>,
    remote_socket_addr: SocketAddr,
) {
    let mut packetizer = rtp::packetizer::new_packetizer(
        240,
        0,
        0,
        Box::new(G711Payloader::default()),
        Box::new(new_fixed_sequencer(0)),
        8_000,
    );
    while let Some(pcm_samples) = bridge_rx.next().await {
        let ulaw_samples = pcm_samples
            .iter()
            .tuple_windows()
            .map(|(high_byte, low_byte)| {
                let pcm_sample = i16::from_be_bytes([*low_byte, *high_byte]);
                encode_ulaw(pcm_sample)
            })
            .collect::<Bytes>();
        match packetizer.packetize(&ulaw_samples, ulaw_samples.len() as u32) {
            Ok(packets) => {
                for packet in packets.iter() {
                    use webrtc_util::Marshal as _;
                    match packet.marshal() {
                        Ok(raw_packet) => {
                            if let Err(e) = rtp_sock.send_to(&raw_packet, remote_socket_addr).await
                            {
                                log::error!("failed to send RTP socket data: {e:?}");
                                return;
                            }
                        }
                        Err(e) => {
                            log::error!("failed to marshal RTP packet: {e:?}");
                        }
                    }
                }
            }
            Err(e) => {
                log::error!("failed to packetize RTP payload: {e:?}");
            }
        }
    }
}

async fn rtp_to_bridge(
    tx: UnboundedSender<Bytes>,
    rtp_sock: Arc<UdpSocket>,
    remote_socket_addr: SocketAddr,
) {
    loop {
        let mut buf = vec![0u8; 512];
        match rtp_sock.recv_from(&mut buf).await {
            Ok((n, socket_addr)) if socket_addr == remote_socket_addr => {
                use webrtc_util::Unmarshal as _;
                buf.truncate(n);
                let mut buf = Bytes::copy_from_slice(&buf);
                match rtp::packet::Packet::unmarshal(&mut buf) {
                    Ok(packet) => {
                        log::trace!("recv RTP packet: {packet}");
                        let pcm_samples = packet
                            .payload
                            .iter()
                            .map(|ulaw_sample| {
                                let pcm_sample = decode_ulaw(*ulaw_sample);
                                pcm_sample.to_be_bytes()
                            })
                            .flatten()
                            .collect::<Vec<_>>();
                        if let Err(_) = tx.unbounded_send(Bytes::copy_from_slice(&pcm_samples)) {
                            return;
                        }
                    }
                    Err(e) => {
                        log::warn!("invalid packet received on RTP socket: {e:?}");
                    }
                }
            }
            Ok((_, socket_addr)) => {
                log::warn!(
                    "received unrelated data on RTP packet from {socket_addr}, when expected {remote_socket_addr}"
                );
            }
            Err(e) => {
                log::error!("failed to recv RTP socket data: {e:?}");
                return;
            }
        }
    }
}

async fn call_audio_to_ai(tx: futures_channel::mpsc::UnboundedSender<Message>) {
    let mut stdin = tokio::io::stdin();
    loop {
        let mut buf = vec![0; 1024];
        let n = match stdin.read(&mut buf).await {
            Err(_) | Ok(0) => break,
            Ok(n) => n,
        };
        buf.truncate(n);

        let text = String::from_utf8_lossy(&buf).into_owned();

        if text.trim() == "quit" {
            tx.close_channel();
            return;
        }

        let item = Item::try_from(serde_json::json!({
            "type": "message",
            "role": "user",
            "content": [
                {
                    "type": "input_text",
                    "text": text
                }
            ]
        }))
        .unwrap();

        let event: ConversationItemCreateEvent = item.into();
        let event_json = serde_json::to_vec(&event).unwrap();
        let message: Message = event_json.into();
        tx.unbounded_send(message).unwrap();
    }
}
