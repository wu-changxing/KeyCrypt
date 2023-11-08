use axum::{routing::get, Router, Json};
use std::net::SocketAddr;
use serde::{Deserialize, Serialize};

#[tokio::main]
async fn main() {
    // define our app routes
    let app = Router::new()
        .route("/", get(root));

    // build our address
    let addr = SocketAddr::from(([127, 0, 0, 1], 8080));
    println!("Listening on {}", addr);

    // run our app
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}

async fn root() -> &'static str {
    "Welcome to KeyCrypt - Your Privacy-First Keyboard Backend!"
}
