use super::app_state::AppState;
use crate::repo::directory_repository::DirectoryRepository;
use crate::repo::file_repository::{self, FileRepository};
use crate::repo::mongo_user_repository::MongoUserRepository;
use crate::repo::user_repository::UserRepository;
use crate::repo::utils::concat_paths;
use crate::{auth::JWTKeys, repo::mock_user_repository::MockUserRepository};
use async_trait::async_trait;
use jsonwebtoken::{DecodingKey, EncodingKey};
use std::path::PathBuf;
use std::{env, fs, path::Path};

pub struct ProductionState {
    jwt_keys: JWTKeys,
    media_root: String,
    user_repository: MongoUserRepository,
    directory_repository: DirectoryRepository,
    file_repository: FileRepository,
}

impl ProductionState {
    pub async fn new() -> Self {
        let jwt_secret =
            env::var("JWT_SECRET").expect("JWT_SECRET environment variable is not set.");
        let mongodb_uri =
            env::var("MONGODB_URI").expect("MONGODB_URI environment variable is not set.");

        let encoding_key = EncodingKey::from_secret(jwt_secret.as_ref());
        let decoding_key = DecodingKey::from_secret(jwt_secret.as_ref());
        let jwt_keys = JWTKeys {
            encoding_key,
            decoding_key,
        };

        let media_root = env::var("TURBO_MEDIA_ROOT")
            .expect("TURBO_MEDIA_ROOT environment variable is not set.");
        let thumbnail_dir = concat_paths(&media_root, "_thumbnails");

        if !Path::new(&media_root).exists() {
            fs::create_dir(&media_root)
                .expect(&format!("Failed to create media root. {}", &media_root));

            if !thumbnail_dir.exists() {
                fs::create_dir(&thumbnail_dir).expect("Failed to create thumbnail directory.");
            }
        }

        let user_repository = MongoUserRepository::new(&mongodb_uri).await; // this will be replaced by mongo repository
        let directory_repository = DirectoryRepository {
            media_root: media_root.to_owned(),
            shared_with_me: PathBuf::from("shared_with_me"),
        };

        let file_repository = FileRepository {
            media_root: media_root.to_owned(),
            thumbnail_dir,
        };

        Self {
            jwt_keys,
            media_root,
            user_repository,
            directory_repository,
            file_repository,
        }
    }
}

impl AppState for ProductionState {
    fn get_jwt_keys(&self) -> &JWTKeys {
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

    fn get_file_repository(&self) -> &FileRepository {
        &self.file_repository
    }
}
