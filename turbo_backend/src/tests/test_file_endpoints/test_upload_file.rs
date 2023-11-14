use std::io::Write;
use std::{fs, path::Path, sync::Arc};

use actix_multipart::Multipart;
use actix_web::{
    body::BoxBody,
    http, test,
    web::{self, Bytes, Data},
    App,
};

use serde_json::json;
use std::collections::hash_map::DefaultHasher;
use std::hash::{Hash, Hasher};

use crate::{
    api::{
        directory_endpoints::create_directory,
        user_endpoints::{create_user, login},
    },
    auth::TokenResponse,
    state::{app_state::AppState, test_state::TestState},
    tests::common::{create_user_helper, get_auth_token_helper, init_app},
};

#[actix_web::test]
async fn test_upload_file() {
    let media_root = "./test_media_root";
    let app = init_app().await;

    let username = "test";
    create_user_helper(&app, username, "password").await;
    let auth_token = get_auth_token_helper(&app, username, "password").await;

    let encoded_media_path = urlencoding::encode(&username);

    // Create a test multipart request
    let mut request = test::TestRequest::post()
        .uri(&format!("/files/{}", encoded_media_path))
        .insert_header((http::header::AUTHORIZATION, auth_token))
        .insert_header((
            http::header::CONTENT_TYPE,
            "multipart/form-data; boundary=boundary"        ))
        .set_payload(Bytes::from_static(b"--boundary\r\ncontent-type: application/octet-stream\r\ncontent-disposition: form-data; name=\"file\"; filename=\"image.jpg\";\r\n\r\nfiledata\r\n--boundary--"))
        .to_request();

    let response = test::call_service(&app, request).await;

    // assert response status is CREATED
    assert_eq!(response.status(), 200);
    let file_media_path = format!("{}/{}", username, "image.jpg");
    let file_fs_path = format!("{}/{}", media_root, file_media_path);

    let thumbnail_fs_path = format!("{}/{}/_thumbnails/image.jpg", media_root, username);
    assert!(Path::new(&file_fs_path).exists());
    assert!(Path::new(&thumbnail_fs_path).exists());
}
