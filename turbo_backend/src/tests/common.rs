use actix_http::{body::MessageBody, Request};
use actix_service::Service;
use actix_web::{
    dev::{HttpServiceFactory, ServiceResponse},
    http,
    test::{self},
    web::{self, scope},
    App, Error,
};
use serde_json::json;
use std::sync::Arc;

use actix_web::web::Data;

use crate::{
    api::{
        directory_endpoints::{
            create_directory, delete_directory, get_directory, rename_directory, share_directory,
        },
        file_endpoints::{get_file, upload_file},
        user_endpoints::{create_user, login},
    },
    auth::TokenResponse,
    state::{app_state::AppState, test_state::TestState},
};

pub async fn init_app(
) -> impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error> {
    let app_state: Data<Arc<dyn AppState + Sync + Send>> =
        Data::new(Arc::new(TestState::new().await) as Arc<dyn AppState + Sync + Send>);
    test::init_service(
        App::new()
            .app_data(app_state)
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
            ),
    )
    .await
}

pub async fn create_user_helper(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    username: &str,
    password: &str,
) {
    let request_data = json!({
        "username": username,
        "password": password
    });

    test::TestRequest::post()
        .uri("/users")
        .insert_header((http::header::CONTENT_TYPE, "application/json"))
        .set_payload(request_data.clone().to_string())
        .send_request(&app)
        .await;
}

pub async fn get_auth_token_helper(
    app: impl Service<Request, Response = ServiceResponse<impl MessageBody>, Error = Error>,
    username: &str,
    password: &str,
) -> String {
    let request_data = json!({
        "username": username,
        "password": password
    });

    let response = test::TestRequest::post()
        .uri("/login")
        .insert_header((http::header::CONTENT_TYPE, "application/json"))
        .set_payload(String::from(request_data.to_string()))
        .send_request(&app)
        .await;

    let response_body = test::read_body(response).await;
    let token_response: TokenResponse = serde_json::from_slice(&response_body.to_vec()).unwrap();
    token_response.token
}
