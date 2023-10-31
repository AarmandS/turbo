use std::{fs::File, io::Write, path::Path};

use actix_files::NamedFile;
use actix_multipart::Field;
use futures::TryStreamExt;

use super::utils::concat_paths;

pub struct FileRepository {
    pub media_root: String, // media root should be pathbuf
}

impl FileRepository {
    pub async fn upload_file(&self, media_path: &str, mut file: Field) -> Result<(), ()> {
        // handle image and video seperatly
        // return err if unknown or unsupported file type
        // maybe the unknown should be unsupported instead
        // create thumbnail differently for video and image
        // replace unwraps
        let file_media_path = concat_paths(
            media_path,
            file.content_disposition().get_filename().unwrap(),
        );
        let fs_path = concat_paths(&self.media_root, file_media_path.to_str().unwrap());
        let mut saved_file: File = File::create(fs_path).unwrap();
        while let Ok(Some(chunk)) = file.try_next().await {
            let _ = saved_file.write_all(&chunk).unwrap();
        }

        Ok(())
    }

    pub async fn get_file(&self, media_path: &str) -> Option<NamedFile> {
        let fs_path = concat_paths(&self.media_root, media_path);
        if fs_path.exists() {
            actix_files::NamedFile::open_async(fs_path).await.ok()
        } else {
            None
        }
    }

    pub async fn rename_file(&self, media_path: &str, new_name: &str) -> Result<(), ()> {
        Ok(())
    }

    pub async fn delete_file(&self, media_path: &str) -> Result<(), ()> {
        Ok(())
    }
}
