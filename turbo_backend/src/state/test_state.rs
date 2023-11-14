use super::app_state::AppState;
use crate::repo::directory_repository::DirectoryRepository;
use crate::repo::file_repository::FileRepository;
use crate::repo::user_repository::UserRepository;
use crate::repo::utils::concat_paths;
use crate::{auth::JwtKeys, repo::mock_user_repository::MockUserRepository};
use async_trait::async_trait;
use jsonwebtoken::{DecodingKey, EncodingKey};
use std::path::PathBuf;
use std::{fs, path::Path};

pub struct TestState {
    jwt_keys: JwtKeys,
    media_root: String,
    user_repository: MockUserRepository,
    directory_repository: DirectoryRepository,
    file_repository: FileRepository,
}

impl TestState {
    pub async fn new() -> Self {
        let jwt_secret = String::from("very_secret_secret");
        let encoding_key = EncodingKey::from_secret(jwt_secret.as_ref());
        let decoding_key = DecodingKey::from_secret(jwt_secret.as_ref());
        let jwt_keys = JwtKeys {
            encoding_key,
            decoding_key,
        };

        let media_root = String::from("./test_media_root");
        let thumbnail_dir = concat_paths(&media_root, "_thumbnails");

        if !Path::new(&media_root).exists() {
            fs::create_dir(&media_root).expect(&format!(
                "Failed to create test media root. {}",
                &media_root
            ));

            if !thumbnail_dir.exists() {
                fs::create_dir(&thumbnail_dir).expect("Failed to create thumbnail directory.");
            }
        }

        let user_repository = MockUserRepository::new().await;
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

#[async_trait]
impl AppState for TestState {
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

    fn get_file_repository(&self) -> &FileRepository {
        &self.file_repository
    }
}

impl Drop for TestState {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.media_root);
    }
}
