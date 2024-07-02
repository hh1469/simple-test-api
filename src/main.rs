use std::net::TcpListener;

use clap::Parser;
use simple_test_api::startup;

#[derive(Debug, Parser)]
struct Cli {
    #[arg(short, long, default_value_t = String::from("127.0.0.1:8080"))]
    address: String,
}

#[tokio::main]
async fn main() -> std::io::Result<()> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    let cli = Cli::parse();

    log::info!("listen on: {}", &cli.address);

    let listener = TcpListener::bind(cli.address).expect("failed to bind to address");

    startup::run(listener)?.await
}
