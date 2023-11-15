use crate::models::directory::Directory;
use crate::models::media_file::MediaFile;
use crate::repo::utils::{get_file_type, FileType};
use std::collections::HashMap;
use std::ffi::OsStr;
use std::os::unix::fs::symlink;
use std::{fs, vec};

use std::path::{Path, PathBuf};

use super::utils::{concat_paths, get_last_path_element, replace_last_path_element};

pub enum DirectoryRepositoryError {
    DirectoryAlreadyExists,
    FailedToCreateDirectory,
    UserRootDirectoryDoesNotExist,
    FailedToCreateSymlink,
    DirectoryDoesNotExist,
    FailedToDeleteDirectory,
    FailedToRenameDirectory,
}

pub struct DirectoryRepository {
    pub media_root: String, // media root should be pathbuf
    pub shared_with_me: PathBuf,
}

// this could be a FS repository common for files and dirs
impl DirectoryRepository {
    pub fn create_directory(&self, media_path: &str) -> Result<(), DirectoryRepositoryError> {
        let fs_path = concat_paths(&self.media_root, media_path);
        if !fs_path.exists() {
            match fs::create_dir(&fs_path) {
                Ok(_) => {
                    let thumbnail_dir = concat_paths(fs_path.to_str().unwrap(), "_thumbnails");
                    match fs::create_dir(&thumbnail_dir) {
                        Ok(_) => Ok(()),
                        Err(_) => Err(DirectoryRepositoryError::FailedToCreateDirectory),
                    }
                }
                Err(_) => Err(DirectoryRepositoryError::FailedToCreateDirectory),
            }
        } else {
            Err(DirectoryRepositoryError::DirectoryAlreadyExists)
        }
    }

    pub fn get_directory(&self, media_path: &str) -> Option<Directory> {
        let fs_path = concat_paths(&self.media_root, media_path);
        match fs::read_dir(&fs_path) {
            Ok(read_dir) => {
                let mut directory = Directory::new(media_path.to_owned());

                for entry in read_dir {
                    let entry = &entry.ok()?;
                    let metadata = fs::metadata(entry.path()).ok()?;
                    let name = entry.file_name().clone().into_string().ok()?;

                    // this is only valid for sharing directories
                    if (metadata.is_dir() || metadata.is_symlink()) && name != "_thumbnails" {
                        directory.directories.push(name);
                    } else if metadata.is_file() {
                        let file = MediaFile {
                            thumbnail: format!("_thumbnails/{}.png", name),
                            full_size: name.clone(), // maybe can avoid cloning
                        };

                        match get_file_type(&name) {
                            FileType::Image => directory.images.push(file),
                            FileType::Video => directory.videos.push(file),
                            FileType::Unknown => {}
                        }
                    }
                }

                println!("{:?}", serde_json::to_string(&directory));

                Some(directory)
            }
            Err(_) => None,
        }
    }

    pub fn share_directory(
        &self,
        media_path: &str,
        username: &str,
    ) -> Result<(), DirectoryRepositoryError> {
        // nme kell ez az fs path terminologia
        let original_dir = concat_paths(&self.media_root, media_path);
        let user_root_dir = concat_paths(&self.media_root, username);

        if !user_root_dir.exists() {
            return Err(DirectoryRepositoryError::UserRootDirectoryDoesNotExist);
        }

        // this path points to the directory which stores the directories,
        // which have been shared with the given user
        let user_shared_with_me_dir: PathBuf = [user_root_dir, self.shared_with_me.clone()]
            .iter()
            .collect();

        // this is the path of the newly shared directory
        let user_shared_dir: PathBuf = [
            user_shared_with_me_dir.clone(),
            PathBuf::from(get_last_path_element(media_path)),
        ]
        .iter()
        .collect();

        // itt a symlinket kellene checkelni mert most 500at ad vissza
        // 409 helyett
        if user_shared_dir.exists() {
            return Err(DirectoryRepositoryError::DirectoryAlreadyExists);
            // return already exists error
            // or increment count, append new to the end or smth or (1)
        } else if !user_shared_with_me_dir.exists() {
            fs::create_dir(user_shared_with_me_dir)
                .or(Err(DirectoryRepositoryError::UserRootDirectoryDoesNotExist))?;
        }

        symlink(original_dir, user_shared_dir)
            .or(Err(DirectoryRepositoryError::FailedToCreateSymlink))?;

        Ok(())
        // create symbolic link return ok

        // if the username's shared_with_me directory exists, then create a symbolic link
        // to the given directory in that directory, if it does not exist, do the same,
        // but create the directory first

        // share with non existant user, should fail
        // already shared should fail also

        // what should happen if

        // ha mar letezik akkor noveljuk a szamot egyel, az nem jo, inkabb faileljen mer ugy de amugy mukodne
    }

    pub fn rename_directory(
        &self,
        media_path: &str,
        new_name: &str,
    ) -> Result<(), DirectoryRepositoryError> {
        let from_fs_path = concat_paths(&self.media_root, media_path);

        let to_media_path = replace_last_path_element(media_path, new_name);
        let to_fs_path = concat_paths(&self.media_root, &to_media_path);

        if !from_fs_path.exists() {
            return Err(DirectoryRepositoryError::DirectoryDoesNotExist);
        }

        if to_fs_path.exists() {
            return Err(DirectoryRepositoryError::DirectoryAlreadyExists);
        }

        fs::rename(from_fs_path, to_fs_path)
            .or(Err(DirectoryRepositoryError::FailedToRenameDirectory))?;

        Ok(())
    }

    pub fn delete_directory(&self, media_path: &str) -> Result<(), DirectoryRepositoryError> {
        // csak siman kitorolni ha letezik, ha nem akkor 404
        // megcsinalni hogy
        let fs_path = concat_paths(&self.media_root, media_path);
        // this function does not follow symbolic links, it just deletes the link itself
        // so only the owner can delete shared directories
        if !fs_path.exists() {
            return Err(DirectoryRepositoryError::DirectoryDoesNotExist);
        }

        fs::remove_dir_all(fs_path).or(Err(DirectoryRepositoryError::FailedToDeleteDirectory))
    }
}
