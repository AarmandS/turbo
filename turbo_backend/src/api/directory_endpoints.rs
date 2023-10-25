use crate::{
    auth::{user_has_permission, AuthenticationToken},
    models::directory::{self, Directory, DirectoryRename, DirectoryShare},
    repo::{directory_repository::DirectoryRepositoryError, user_repository},
    state::app_state::AppState,
};
use actix_web::{
    http::header::ContentType,
    web::{self, Data},
    HttpRequest, HttpResponse, Responder,
};
use std::{fs, path};
use std::{path::PathBuf, sync::Arc};

pub async fn get_directory(
    auth_token: AuthenticationToken,
    state: web::Data<Arc<dyn AppState + Sync + Send>>,
    media_path: web::Path<String>,
) -> impl Responder {
    let decoded_media_path = urlencoding::decode(&media_path)
        .expect("UTF-8")
        .into_owned();

    if !user_has_permission(&auth_token.sub, &decoded_media_path) {
        return HttpResponse::Forbidden().body("The user cannot access the given resource.");
    }

    let dir_repo = state.get_directory_repository();

    match dir_repo.get_directory(&decoded_media_path) {
        Some(dir) => {
            let json = serde_json::to_string(&dir).expect("Failed to serialize directory");
            HttpResponse::Ok()
                .content_type(ContentType::json())
                .body(json)
        }
        None => HttpResponse::NotFound().body("Directory does not exist."),
    }
}

pub async fn create_directory(
    auth_token: AuthenticationToken,
    state: web::Data<Arc<dyn AppState + Sync + Send>>,
    media_path: web::Path<String>,
) -> impl Responder {
    let decoded_media_path = urlencoding::decode(&media_path)
        .expect("UTF-8")
        .into_owned();

    if !user_has_permission(&auth_token.sub, &decoded_media_path) {
        return HttpResponse::Forbidden().body("The user cannot access the given resource.");
    }

    let dir_repo = state.get_directory_repository();
    match dir_repo.create_directory(&decoded_media_path) {
        Ok(_) => HttpResponse::Created().body("Successfully created directory."),
        Err(DirectoryRepositoryError::DirectoryAlreadyExists) => {
            HttpResponse::Conflict().body("The user's root directory already exists.")
        }
        _ => HttpResponse::InternalServerError().body("Failed to create user's root directory."),
    }
}

// this would work the same way with files i guess
// try it with files
pub async fn share_directory(
    auth_token: AuthenticationToken,
    state: web::Data<Arc<dyn AppState + Sync + Send>>,
    share: web::Json<DirectoryShare>,
) -> impl Responder {
    if !user_has_permission(&auth_token.sub, &share.media_path) {
        return HttpResponse::Forbidden().body("The user cannot access the given resource.");
    }

    let dir_repo = state.get_directory_repository();
    println!("user {}", &share.username);

    match dir_repo.share_directory(&share.media_path, &share.username) {
        Ok(_) => HttpResponse::Ok().body("Succesfully shared directory."),
        Err(DirectoryRepositoryError::DirectoryAlreadyExists) => HttpResponse::Conflict()
            .body("The user already has a shared directory with the same name."),
        Err(DirectoryRepositoryError::UserRootDirectoryDoesNotExist) => {
            HttpResponse::BadRequest().body("The user's root directory does not exist.")
        }
        _ => HttpResponse::InternalServerError().body("Failed to share directory with user."),
    }
}

pub async fn rename_directory(
    auth_token: AuthenticationToken,
    state: web::Data<Arc<dyn AppState + Sync + Send>>,
    media_path: web::Path<String>,
    rename: web::Json<DirectoryRename>,
) -> impl Responder {
    let decoded_media_path = urlencoding::decode(&media_path)
        .expect("UTF-8")
        .into_owned();

    if !user_has_permission(&auth_token.sub, &decoded_media_path) {
        return HttpResponse::Forbidden().body("The user cannot access the given resource.");
    }

    let dir_repo = state.get_directory_repository();

    match dir_repo.rename_directory(&decoded_media_path, &rename.new_name) {
        Ok(_) => HttpResponse::Ok().body("Succesfully renamed directory."),
        Err(DirectoryRepositoryError::DirectoryDoesNotExist) => {
            HttpResponse::NotFound().body("Directory does not exist")
        }
        Err(DirectoryRepositoryError::DirectoryAlreadyExists) => {
            HttpResponse::Conflict().body("A directory with the given name already exists.")
        }
        _ => HttpResponse::InternalServerError().body("Failed to rename directory."),
    }
}

pub async fn delete_directory(
    auth_token: AuthenticationToken,
    state: web::Data<Arc<dyn AppState + Sync + Send>>,
    media_path: web::Path<String>,
) -> impl Responder {
    let decoded_media_path = urlencoding::decode(&media_path)
        .expect("UTF-8")
        .into_owned();

    if !user_has_permission(&auth_token.sub, &decoded_media_path) {
        return HttpResponse::Forbidden().body("The user cannot access the given resource.");
    }

    let dir_repo = state.get_directory_repository();

    match dir_repo.delete_directory(&decoded_media_path) {
        Ok(_) => HttpResponse::Ok().body("Succesfully deleted directory."),
        Err(DirectoryRepositoryError::DirectoryDoesNotExist) => {
            HttpResponse::NotFound().body("Directory does not exist,")
        }
        Err(_) => HttpResponse::InternalServerError().body("Failed to delete directory."),
    }
}
