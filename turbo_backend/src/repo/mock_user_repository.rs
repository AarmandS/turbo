use std::sync::{Arc, Mutex};
use std::vec;

use async_trait::async_trait;

use crate::models::directory::{self, Directory};
use crate::models::user::User;

use super::user_repository::UserRepository;

pub struct MockUserRepository {
    users: Arc<Mutex<Vec<User>>>,
}

impl MockUserRepository {
    pub async fn new() -> Self {
        let users = Arc::new(Mutex::new(vec![]));
        MockUserRepository { users }
    }
}

#[async_trait]
impl UserRepository for MockUserRepository {
    async fn create_user(&self, new_user: User) -> Result<(), ()> {
        let mut users_vec = self.users.lock().unwrap();
        for user in users_vec.iter() {
            if new_user.username == user.username {
                return Err(());
            }
        }

        users_vec.push(new_user);

        Ok(())
    }

    async fn authenticate_user(&self, credentials: &User) -> Result<(), ()> {
        let user = self.get_user(&credentials.username).await.ok_or(())?;

        if credentials.username == user.username && credentials.password == user.password {
            return Ok(());
        }

        Err(())
    }

    async fn get_user(&self, username: &str) -> Option<User> {
        let users_vec = self.users.lock().unwrap();
        for user in users_vec.iter() {
            if user.username == username {
                return Some(user.clone());
            }
        }
        None
    }

    async fn get_users(&self) -> &Vec<User> {
        todo!()
    }

    async fn delete_user(&self, username: &str) -> Result<(), ()> {
        todo!()
    }
}
