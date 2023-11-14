use std::{
    fs::File,
    io::{BufReader, Cursor, Write},
    path::{Path, PathBuf},
};

use std::process::Command;

use actix_files::NamedFile;
use actix_multipart::Field;
use futures::TryStreamExt;
use mime::Mime;
use thumbnailer::{create_thumbnails, ThumbnailSize};

use super::utils::{concat_paths, replace_extension};

pub struct FileRepository {
    pub media_root: String, // media root should be pathbuf
    pub thumbnail_dir: PathBuf,
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

        let mut saved_file: File = File::create(&fs_path).unwrap();
        while let Ok(Some(chunk)) = file.try_next().await {
            let _ = saved_file.write_all(&chunk).unwrap();
        }

        let filename = file.content_disposition().get_filename().unwrap();
        let file_mime = file.content_type().unwrap();
        self.create_thumbnail(&fs_path, media_path, filename, file_mime);

        Ok(())
    }

    fn create_thumbnail(
        &self,
        file_fs_path: &PathBuf,
        media_path: &str,
        filename: &str,
        mime: &Mime,
    ) {
        let thumbnail_fs_path = format!(
            "{}/{}/_thumbnails/{}",
            self.media_root,
            media_path,
            replace_extension(filename, "png") // replace filename extension with png in every case
        );
        match mime.type_() {
            mime::IMAGE => {
                println!("{:?}", mime.type_());
                let file = File::open(file_fs_path).unwrap();
                let reader = BufReader::new(file);
                let mut thumbnails = create_thumbnails(
                    reader,
                    mime::IMAGE_JPEG, // this has to be exact, also on the flutter side, gotta decide what formats to support
                    // i guess to start with jpeg, png, and mp4 are enough
                    [ThumbnailSize::Custom((140, 140))],
                )
                .unwrap();

                let thumbnail = thumbnails.pop().unwrap();
                let mut thumbnail_file: File = File::create(thumbnail_fs_path).unwrap();
                thumbnail.write_png(&mut thumbnail_file).unwrap();
            }
            mime::VIDEO => {
                let command = Command::new("ffmpeg")
                    .args([
                        "-i",
                        file_fs_path.to_str().unwrap(),
                        "-vf",
                        "select=eq(n\\,0),scale=140:140",
                        "-vframes",
                        "1",
                        &thumbnail_fs_path,
                    ])
                    .spawn();
            }
            _ => {
                println!("{:?}", mime.type_())
            }
        }
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
