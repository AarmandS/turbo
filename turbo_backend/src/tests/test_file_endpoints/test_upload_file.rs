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
async fn test_upload_file_jpg() {
    let media_root = "./test_media_root";
    let app = init_app().await;

    let username = "test";
    create_user_helper(&app, username, "password").await;
    let auth_token = get_auth_token_helper(&app, username, "password").await;

    let encoded_media_path = urlencoding::encode(&username);

    // let file_path = "./src/tests/assets/image.jpg";
    // let file_content = fs::read(file_path).unwrap();
    // let encoded = base64::encode(file_content);
    // println!("{}", encoded);

    let boundary = "boundary";
    let mut payload = format!("--{}\r\n", boundary);
    payload += "content-type: image/png\r\n";
    payload += "content-disposition: form-data; name=\"file\"; filename=\"image.png\";\r\n\r\n";
    payload += "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";
    payload += &format!("\r\n--{}--\r\n", boundary);

    // Create a test multipart request
    let mut request = test::TestRequest::post()
        .uri(&format!("/files/{}", encoded_media_path))
        .insert_header((http::header::AUTHORIZATION, auth_token))
        .insert_header((
            http::header::CONTENT_TYPE,
            "multipart/form-data; boundary=boundary",
        ))
        .set_payload(Bytes::from(payload))
        .to_request();

    let response = test::call_service(&app, request).await;

    // assert response status is CREATED
    assert_eq!(response.status(), 200);
    let file_media_path = format!("{}/{}", username, "image.png");
    let file_fs_path = format!("{}/{}", media_root, file_media_path);

    let thumbnail_fs_path = format!("{}/{}/_thumbnails/image.png", media_root, username);
    assert!(Path::new(&file_fs_path).exists());
    assert!(Path::new(&thumbnail_fs_path).exists());
}
