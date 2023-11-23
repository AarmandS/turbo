use crate::models::user::User;
use async_trait::async_trait;
// ez az error masra van mint amire nekem kell
use futures::stream::{StreamExt, TryStreamExt};
use mongodb::{
    bson::{doc, extjson::de::Error},
    options::{FindOneOptions, InsertOneOptions},
    results::InsertOneResult,
    Client, Collection,
};

use super::user_repository::UserRepository;

pub struct MongoUserRepository {
    user_collection: Collection<User>,
}

impl MongoUserRepository {
    pub async fn new(mongodb_uri: &str) -> Self {
        // this should come from env variable
        // replace unwraps with expect
        let client_options = mongodb::options::ClientOptions::parse(mongodb_uri)
            .await
            .unwrap();
        let client = Client::with_options(client_options).unwrap();
        let db = client.database("turbo");
        let user_collection: Collection<User> = db.collection("users");
        MongoUserRepository { user_collection }
    }

    // pub async fn create_user(&self, new_user: User) -> Result<(), Error> {
    //     let new_doc = User {
    //         id: None,
    //         username: new_user.username,
    //         password: new_user.password,
    //     };
    //     self.user_collection
    //         .insert_one(new_doc, None)
    //         .await
    //         .expect("Error creating user");
    //     Ok(())
    // }

    // pub async fn get_users(&self) -> Vec<User> {
    //     let mut cursor = self
    //         .user_collection
    //         .find(None, None)
    //         .await
    //         .expect("got cursor");
    //     cursor.try_collect().await.expect("could not await")
    // }

    // pub async fn get_user(&self, username: String) -> Option<User> {}
}

#[async_trait]
impl UserRepository for MongoUserRepository {
    async fn create_user(&self, new_user: User) -> Result<(), ()> {
        match self.get_user(&new_user.username).await {
            Some(_) => Err(()), // return user already exists
            None => {
                self.user_collection
                    .insert_one(new_user, None)
                    .await
                    .expect("Error creating user");
                // return error here too

                Ok(())
            }
        }
    }

    async fn authenticate_user(&self, credentials: &User) -> Result<(), ()> {
        match self.get_user(&credentials.username).await {
            Some(user) => {
                if credentials.username == user.username && credentials.password == user.password {
                    Ok(())
                } else {
                    Err(()) // return username pwd dont match or auth failed for both cases
                }
            }
            None => {
                Err(()) // return user does not exist
            }
        }
    }

    async fn get_user(&self, username: &str) -> Option<User> {
        self.user_collection
            .find_one(doc! { "username": username }, None)
            .await
            .expect("MongoDB error when getting user.")
    }
}
