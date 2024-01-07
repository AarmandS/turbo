use async_trait::async_trait;

use crate::models::directory::Directory;
use crate::models::user::{self, User, UserInfo};

#[async_trait]
pub trait UserRepository {
    async fn create_user(&self, new_user: User) -> Result<(), ()>;
    async fn authenticate_user(&self, user: &User) -> Result<(), ()>;
    async fn get_user(&self, username: &str) -> Option<User>;
    async fn get_user_info(&self, username: &str) -> UserInfo {
        UserInfo {
            username: username.clone().to_owned(),
            space_taken: 0,
            files_uploaded: 0,
            // profile_picture: "",
        }
    }
}
