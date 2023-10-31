use std::{fs, path::Path, sync::Arc};

use actix_web::{
    http, test,
    web::{self, Data},
    App,
};
use serde_json::json;

use crate::{
    api::user_endpoints::create_user,
    state::{app_state::AppState, test_state::TestState},
    tests::common::init_app,
};

#[actix_web::test]
async fn test_user_create() {
    let media_root = "./test_media_root";
    let app = init_app().await;

    let username = "test";
    let request_data = json!({
        "username": username,
        "password": "password"
    });

    let request = test::TestRequest::post()
        .uri("/users")
        .insert_header((http::header::CONTENT_TYPE, "application/json"))
        .set_payload(request_data.to_string())
        .to_request();

    let response = test::call_service(&app, request).await;

    assert_eq!(response.status(), 201);

    let user_root_directory = format!("{}/{}", media_root, username);
    assert!(Path::new(&user_root_directory).exists())
}

#[actix_web::test]
async fn test_user_create_username_taken() {
    let app = init_app().await;

    let request_data = json!({
        "username": "test",
        "password": "password"
    });

    let mut response = None;

    for _ in 0..2 {
        let request = test::TestRequest::post()
            .uri("/users")
            .insert_header((http::header::CONTENT_TYPE, "application/json"))
            .set_payload(request_data.to_string())
            .to_request();

        response = Some(test::call_service(&app, request).await);
    }

    assert_eq!(response.unwrap().status(), 409);
}

#[actix_web::test]
async fn test_user_create_directory_taken() {
    let media_root = "./test_media_root";
    let app = init_app().await;

    let user_dir = format!("{}/{}", media_root, "test");
    let _ = fs::create_dir(&user_dir);

    let request_data = json!({
        "username": "test",
        "password": "password"
    });

    let request = test::TestRequest::post()
        .uri("/users")
        .insert_header((http::header::CONTENT_TYPE, "application/json"))
        .set_payload(request_data.to_string())
        .to_request();

    let response = test::call_service(&app, request).await;

    assert_eq!(response.status(), 409); // check the response message too
}
