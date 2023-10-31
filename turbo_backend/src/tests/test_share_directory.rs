use std::{fs, path::Path, sync::Arc};

use actix_web::{
    body::BoxBody,
    http, test,
    web::{self, Bytes, Data},
    App,
};
use serde_json::json;

use crate::{
    api::{
        directory_endpoints::{create_directory, share_directory},
        user_endpoints::{create_user, login},
    },
    auth::TokenResponse,
    models::user,
    state::{app_state::AppState, test_state::TestState},
    tests::common::{create_user_helper, get_auth_token_helper, init_app},
};

#[actix_web::test]
async fn test_share_directory() {
    let media_root = "./test_media_root";
    let app = init_app().await;

    let username = "test";
    let other_username = "other_user";
    let directory_name = "new_directory";

    create_user_helper(&app, username, "password").await;
    let auth_token = get_auth_token_helper(&app, username, "password").await;

    let request_data = json!({
        "username": &other_username,
        "password": "password"
    });

    // create other user
    let request = test::TestRequest::post()
        .uri("/users")
        .insert_header((http::header::CONTENT_TYPE, "application/json"))
        .set_payload(request_data.to_string())
        .to_request();

    let response = test::call_service(&app, request).await;

    let media_path = format!("{}/{}", &username, &directory_name);
    let encoded_media_path = urlencoding::encode(&media_path);

    // create directory
    let request = test::TestRequest::post()
        .uri(&format!("/directories/{}", encoded_media_path))
        .insert_header((http::header::AUTHORIZATION, auth_token.clone()))
        .insert_header((http::header::CONTENT_TYPE, "application/json"))
        .to_request();

    let response = test::call_service(&app, request).await;

    let share_request_data = json!({
        "media_path": format!("{}/{}", username, directory_name),
        "username": "other_user",
    });

    // share directory
    let request = test::TestRequest::post()
        .uri("/share")
        .insert_header((http::header::AUTHORIZATION, auth_token))
        .insert_header((http::header::CONTENT_TYPE, "application/json"))
        .set_payload(share_request_data.to_string())
        .to_request();

    let response = test::call_service(&app, request).await;

    // assert response status is OK
    assert_eq!(response.status(), 200);
    // assert that directory exists in the second users shared with me
    fs::read_link(format!(
        "{}/other_user/shared_with_me/new_directory",
        media_root
    ))
    .expect("Symbolic link was not created.");
}

#[actix_web::test]
async fn test_share_directory_other_user_does_not_exist() {
    let media_root = "./test_media_root";
    let app = init_app().await;

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

    let share_request_data = json!({
        "media_path": media_path,
        "username": "other_user",
    });

    // share directory
    let request = test::TestRequest::post()
        .uri("/share")
        .insert_header((http::header::AUTHORIZATION, auth_token))
        .insert_header((http::header::CONTENT_TYPE, "application/json"))
        .set_payload(share_request_data.to_string())
        .to_request();

    let response = test::call_service(&app, request).await;

    // assert response status is BAD REQUEST
    assert_eq!(response.status(), 400);
}
