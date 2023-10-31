use std::sync::Arc;

use actix_multipart::Multipart;
use actix_web::{http::StatusCode, web, HttpRequest, HttpResponse};
use futures::TryStreamExt;
use mime::Mime;

use crate::{
    auth::{user_has_permission, AuthenticationToken},
    state::app_state::AppState,
};

pub async fn upload_file(
    auth_token: AuthenticationToken,
    state: web::Data<Arc<dyn AppState + Sync + Send>>,
    mut payload: Multipart,
    media_path: web::Path<String>,
) -> HttpResponse {
    let decoded_media_path = urlencoding::decode(&media_path)
        .expect("UTF-8")
        .into_owned();

    if !user_has_permission(&auth_token.sub, &decoded_media_path) {
        return HttpResponse::Forbidden().body("The user cannot access the given resource.");
    }

    if let Ok(Some(mut field)) = payload.try_next().await {
        if field.name() == "file" {
            match state
                .get_file_repository()
                .upload_file(&decoded_media_path, field)
                .await
            {
                Ok(_) => {
                    return HttpResponse::Ok().into();
                }
                Err(_) => {
                    return HttpResponse::InternalServerError().into();
                }
            }
        }
    }
    HttpResponse::BadRequest().into()
}

pub async fn get_file(
    req: HttpRequest,
    auth_token: AuthenticationToken,
    state: web::Data<Arc<dyn AppState + Sync + Send>>,
    media_path: web::Path<String>,
) -> HttpResponse {
    // resource path should be smth like : images/armand/kepek/turbo.jpg url encoded
    // check permissions
    let decoded_media_path = urlencoding::decode(&media_path)
        .expect("UTF-8")
        .into_owned();

    if !user_has_permission(&auth_token.sub, &decoded_media_path) {
        return HttpResponse::Forbidden().body("The user cannot access the given resource.");
    }

    match state
        .get_file_repository()
        .get_file(&decoded_media_path)
        .await
    {
        Some(file) => file.into_response(&req),
        None => HttpResponse::NotFound().into(),
    }
}
