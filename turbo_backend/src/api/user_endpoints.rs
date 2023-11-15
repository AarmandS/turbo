use std::sync::Arc;

use crate::{
    auth::{get_token, TokenResponse},
    models::user::User,
    repo::directory_repository::DirectoryRepositoryError,
    state::app_state::AppState,
};

use actix_web::{
    web::{self, Json},
    HttpResponse, Responder,
};

pub async fn create_user(
    state: web::Data<Arc<dyn AppState + Sync + Send>>,
    new_user: Json<User>,
) -> impl Responder {
    let dir_repo = state.get_directory_repository();
    let user_repo = state.get_user_repository();

    match dir_repo.create_directory(&new_user.username) {
        Ok(_) => {}
        Err(DirectoryRepositoryError::DirectoryAlreadyExists) => {
            return HttpResponse::Conflict().body("The user's root directory already exists.");
        }
        _ => {
            return HttpResponse::InternalServerError()
                .body("Failed to create user's root directory.");
        }
    };

    match user_repo.create_user(new_user.into_inner()).await {
        Ok(_) => HttpResponse::Created().body("Successfully created user."),
        Err(_) => HttpResponse::Conflict().body("User already exists."),
    }
}

pub async fn login(
    state: web::Data<Arc<dyn AppState + Sync + Send>>,
    credentials: Json<User>,
) -> impl Responder {
    let creds = credentials.into_inner();
    let auth_result = state.get_user_repository().authenticate_user(&creds).await;

    match auth_result {
        Ok(_) => {
            let token = get_token(&creds.username, &state.get_jwt_keys().encoding_key);
            let response = TokenResponse { token };
            HttpResponse::Ok().json(response)
        }
        Err(_) => HttpResponse::Unauthorized().body(()),
    }
}
