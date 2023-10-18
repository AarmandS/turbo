use std::{path::Path, sync::Arc};

use actix_web::{
    body::BoxBody,
    http, test,
    web::{self, Bytes, Data},
    App,
};
use serde_json::json;

use crate::{
    api::{
        directory_endpoints::{create_directory, get_directory},
        user_endpoints::{create_user, login},
    },
    auth::TokenResponse,
    state::{app_state::AppState, test_state::TestState},
};

#[actix_web::test]
async fn test_get_directory_after_create() {
    let app_state: Data<Arc<dyn AppState + Sync + Send>> =
        Data::new(Arc::new(TestState::new().await) as Arc<dyn AppState + Sync + Send>);
    let media_root = app_state.get_media_root().to_owned();
    let app = test::init_service(
        App::new()
            .app_data(app_state)
            .route(
                "/directories/{media_path}",
                web::post().to(create_directory),
            )
            .route("/directories/{media_path}", web::get().to(get_directory))
            .route("/users", web::post().to(create_user))
            .route("/login", web::post().to(login)),
    )
    .await;

    let username = "test";
    let directory_name = "new_directory";
    let request_data = json!({
        "username": username,
        "password": "password"
    });

    // create user
    let request = test::TestRequest::post()
        .uri("/users")
        .insert_header((http::header::CONTENT_TYPE, "application/json"))
        .set_payload(request_data.to_string())
        .to_request();

    let response = test::call_service(&app, request).await;

    // get auth token
    let request = test::TestRequest::post()
        .uri("/login")
        .insert_header((http::header::CONTENT_TYPE, "application/json"))
        .set_payload(String::from(request_data.to_string()))
        .to_request();

    let response = test::call_service(&app, request).await;
    let response_body = test::read_body(response).await;
    let token_response: TokenResponse = serde_json::from_slice(&response_body.to_vec()).unwrap();
    let auth_token = token_response.token;

    let media_path = format!("{}/{}", &username, &directory_name);
    let encoded_media_path = urlencoding::encode(&media_path);

    // create directory
    let request = test::TestRequest::post()
        .uri(&format!("/directories/{}", encoded_media_path))
        .insert_header((http::header::AUTHORIZATION, auth_token.clone()))
        .insert_header((http::header::CONTENT_TYPE, "application/json"))
        .to_request();

    let response = test::call_service(&app, request).await;
    assert_eq!(response.status(), 201);

    // assert that directory was created
    let new_directory_fs_path = format!("{}/{}/{}", media_root, username, directory_name);
    assert!(Path::new(&new_directory_fs_path).exists());

    // get directory
    let request = test::TestRequest::get()
        .uri(&format!("/directories/{}", encoded_media_path))
        .insert_header((http::header::AUTHORIZATION, auth_token))
        .insert_header((http::header::CONTENT_TYPE, "application/json"))
        .to_request();

    let response = test::call_service(&app, request).await;
    assert_eq!(response.status(), 200);

    // ez a hashmap rendezetlensege miatt failel
    let body = test::read_body(response).await;
    assert_eq!(
        Bytes::from(
            json!({
                "media_path": "test/new_directory",
                "contents": {
                    "directories": [],
                    "files": []
                }
            })
            .to_string()
        ),
        body
    );
}
