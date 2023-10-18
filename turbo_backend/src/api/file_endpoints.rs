// use crate::{
//     auth::{user_has_permission, AuthenticationToken},
//     models::directory::{self, Directory, DirectoryShare},
//     repo::{directory_repository::DirectoryRepositoryError, user_repository},
//     state::app_state::AppState,
// };
// use actix_web::{
//     http::header::ContentType,
//     web::{self, Data},
//     HttpRequest, HttpResponse, Responder,
// };
// use std::{fs, path};
// use std::{path::PathBuf, sync::Arc};

// pub async fn upload_file(
//     auth_token: AuthenticationToken,
//     state: web::Data<Arc<dyn AppState + Sync + Send>>,
//     media_path: web::Path<String>,
// ) -> impl Responder {
//     let decoded_media_path = urlencoding::decode(&media_path)
//         .expect("UTF-8")
//         .into_owned();

//     if !user_has_permission(&auth_token.sub, &decoded_media_path) {
//         return HttpResponse::Forbidden().body("The user cannot access the given resource.");
//     }

//     let dir_repo = state.get_directory_repository();
//     match dir_repo.create_directory(&decoded_media_path) {
//         Ok(_) => HttpResponse::Created().body("Successfully created directory."),
//         Err(DirectoryRepositoryError::DirectoryAlreadyExists) => {
//             HttpResponse::Conflict().body("The user's root directory already exists.")
//         }
//         _ => HttpResponse::InternalServerError().body("Failed to create user's root directory."),
//     }
// }
