use std::{fs, path::Path, sync::Arc};

use actix_web::{
    http, test,
    web::{self, Data},
    App,
};
use serde_json::json;

use crate::{
    api::user_endpoints::{create_user, login},
    state::{app_state::AppState, test_state::TestState},
    tests::common::init_app,
};

#[actix_web::test]
async fn test_login_success() {
    let app = init_app().await;

    let request_data = json!({
        "username": "test",
        "password": "password"
    });

    // create user
    let request = test::TestRequest::post()
        .uri("/users")
        .insert_header((http::header::CONTENT_TYPE, "application/json"))
        .set_payload(request_data.clone().to_string())
        .to_request();

    let response = test::call_service(&app, request).await;

    assert_eq!(response.status(), 201);

    // get auth token
    let request = test::TestRequest::post()
        .uri("/login")
        .insert_header((http::header::CONTENT_TYPE, "application/json"))
        .set_payload(String::from(request_data.to_string()))
        .to_request();

    let response = test::call_service(&app, request).await;
    assert_eq!(response.status(), 200);
}

#[actix_web::test]
async fn test_login_failure() {
    let app = init_app().await;

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
    assert_eq!(response.status(), 201);

    let incorrect_request_data = json!({
        "username": "test",
        "password": "wordpass"
    });

    let request = test::TestRequest::post()
        .uri("/login")
        .insert_header((http::header::CONTENT_TYPE, "application/json"))
        .set_payload(String::from(incorrect_request_data.to_string()))
        .to_request();

    let response = test::call_service(&app, request).await;
    assert_eq!(response.status(), 401);
}
