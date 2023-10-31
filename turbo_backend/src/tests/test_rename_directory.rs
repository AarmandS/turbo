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
        directory_endpoints::{
            create_directory, delete_directory, get_directory, rename_directory,
        },
        user_endpoints::{create_user, login},
    },
    auth::TokenResponse,
    state::{app_state::AppState, test_state::TestState},
    tests::common::{create_user_helper, get_auth_token_helper, init_app},
};

#[actix_web::test]
async fn test_rename_directory_after_create() {
    let media_root = "./test_media_root";
    let app = init_app().await;

    let username = "test";
    let directory_name = "new_directory";
    create_user_helper(&app, username, "password").await;
    let auth_token = get_auth_token_helper(&app, username, "password").await;

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

    // rename directory
    let directory_new_name = "renamed";
    let request_data = json!({
        "new_name": directory_new_name,
    });

    let request = test::TestRequest::put()
        .uri(&format!("/directories/{}", encoded_media_path))
        .insert_header((http::header::AUTHORIZATION, auth_token))
        .insert_header((http::header::CONTENT_TYPE, "application/json"))
        .set_payload(request_data.to_string())
        .to_request();

    let response = test::call_service(&app, request).await;
    assert_eq!(response.status(), 200);

    // assert that directory with the old name does not exist anymore
    let new_directory_fs_path = format!("{}/{}/{}", media_root, username, directory_name);
    assert!(!Path::new(&new_directory_fs_path).exists());

    // assert that directory with the new name exists
    let new_directory_fs_path = format!("{}/{}/{}", media_root, username, directory_new_name);
    assert!(Path::new(&new_directory_fs_path).exists());
}
