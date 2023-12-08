use crate::{
    auth::JWTKeys,
    repo::{
        directory_repository::DirectoryRepository, file_repository::FileRepository,
        user_repository::UserRepository,
    },
};

pub trait AppState {
    fn get_jwt_keys(&self) -> &JWTKeys;
    fn get_media_root(&self) -> &str;
    fn get_user_repository(&self) -> &dyn UserRepository;
    fn get_directory_repository(&self) -> &DirectoryRepository;
    fn get_file_repository(&self) -> &FileRepository;
}
