mod api;
mod auth;
mod models;
mod repo;
mod state;
mod tests;
use std::sync::Arc;

use crate::state::app_state::AppState;
use crate::state::prod_state::ProductionState;

use actix_cors::Cors;
use actix_web::{
    http,
    middleware::Logger,
    web::{self, scope, Data},
    App, HttpServer,
};
use api::{
    directory_endpoints::{
        create_directory, delete_directory, get_directory, rename_directory, share_directory,
    },
    file_endpoints::{get_file, upload_file},
    user_endpoints::{create_user, login},
};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let app_state: Data<Arc<dyn AppState + Sync + Send>> =
        Data::new(Arc::new(ProductionState::new().await) as Arc<dyn AppState + Sync + Send>);

    std::env::set_var("RUST_LOG", "debug");
    std::env::set_var("RUST_BACKTRACE", "1");
    env_logger::init();

    // why this move, how do closures work
    HttpServer::new(move || {
        let logger = Logger::default();

        let cors_middleware = Cors::default()
            .allow_any_origin()
            .allowed_headers(vec![
                http::header::AUTHORIZATION,
                http::header::CONTENT_TYPE,
            ])
            .allowed_methods(vec!["GET", "POST", "PUT", "DELETE"])
            .max_age(3600);

        App::new()
            .app_data(app_state.clone())
            .wrap(cors_middleware)
            .wrap(logger)
            .route("/users", web::post().to(create_user))
            .route("/login", web::post().to(login))
            .route("/share", web::post().to(share_directory))
            .service(
                scope("/files")
                    .route("/{media_path}", web::post().to(upload_file))
                    .route("/{media_path}", web::get().to(get_file)),
            )
            .service(
                scope("/directories")
                    .route("/{media_path}", web::post().to(create_directory))
                    .route("/{media_path}", web::get().to(get_directory))
                    .route("/{media_path}", web::put().to(rename_directory))
                    .route("/{media_path}", web::delete().to(delete_directory)),
            )
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
