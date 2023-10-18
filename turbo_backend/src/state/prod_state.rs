use super::app_state::AppState;
use crate::repo::directory_repository::DirectoryRepository;
use crate::repo::mongo_user_repository::MongoUserRepository;
use crate::repo::user_repository::UserRepository;
use crate::{auth::JwtKeys, repo::mock_user_repository::MockUserRepository};
use async_trait::async_trait;
use jsonwebtoken::{DecodingKey, EncodingKey};
use std::path::PathBuf;
use std::{env, fs, path::Path};

pub struct ProductionState {
    jwt_keys: JwtKeys,
    media_root: String,
    user_repository: MongoUserRepository,
    directory_repository: DirectoryRepository,
}

impl ProductionState {
    pub async fn new() -> Self {
        let jwt_secret =
            env::var("JWT_SECRET").expect("JWT_SECRET environment variable is not set.");
        let mongodb_uri =
            env::var("MONGODB_URI").expect("MONGODB_URI environment variable is not set.");

        let encoding_key = EncodingKey::from_secret(jwt_secret.as_ref());
        let decoding_key = DecodingKey::from_secret(jwt_secret.as_ref());
        let jwt_keys = JwtKeys {
            encoding_key,
            decoding_key,
        };

        let media_root = env::var("TURBO_MEDIA_ROOT")
            .expect("TURBO_MEDIA_ROOT environment variable is not set.");

        if !Path::new(&media_root).exists() {
            fs::create_dir(&media_root)
                .expect(&format!("Failed to create media root. {}", &media_root));
        }

        let user_repository = MongoUserRepository::new(&mongodb_uri).await; // this will be replaced by mongo repository
        let directory_repository = DirectoryRepository {
            media_root: media_root.to_owned(),
            shared_with_me: PathBuf::from("shared_with_me"),
        };

        Self {
            jwt_keys,
            media_root,
            user_repository,
            directory_repository,
        }
    }
}

#[async_trait]
impl AppState for ProductionState {
    fn get_jwt_keys(&self) -> &JwtKeys {
        &self.jwt_keys
    }

    fn get_media_root(&self) -> &str {
        &self.media_root
    }

    fn get_user_repository(&self) -> &dyn UserRepository {
        &self.user_repository
    }

    fn get_directory_repository(&self) -> &DirectoryRepository {
        &self.directory_repository
    }
}
