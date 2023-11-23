use async_trait::async_trait;

use crate::models::directory::Directory;
use crate::models::user::User;

#[async_trait]
pub trait UserRepository {
    async fn create_user(&self, new_user: User) -> Result<(), ()>;
    async fn authenticate_user(&self, user: &User) -> Result<(), ()>;
    async fn get_user(&self, username: &str) -> Option<User>;
}
