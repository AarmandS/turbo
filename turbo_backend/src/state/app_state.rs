use crate::{
    auth::JwtKeys,
    repo::{directory_repository::DirectoryRepository, user_repository::UserRepository},
};
use async_trait::async_trait;

#[async_trait]
pub trait AppState {
    fn get_jwt_keys(&self) -> &JwtKeys;
    fn get_media_root(&self) -> &str;
    fn get_user_repository(&self) -> &dyn UserRepository;
    fn get_directory_repository(&self) -> &DirectoryRepository;
}
