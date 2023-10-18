use crate::models::directory::Directory;
use std::collections::HashMap;
use std::os::unix::fs::symlink;
use std::{fs, vec};

use std::path::{Path, PathBuf};

pub enum DirectoryRepositoryError {
    DirectoryAlreadyExists,
    FailedToCreateDirectory,
    UserRootDirectoryDoesNotExist,
    FailedToCreateSymlink,
    DirectoryDoesNotExist,
    FailedToDeleteDirectory,
}

pub struct DirectoryRepository {
    pub media_root: String, // media root should be pathbuf
    pub shared_with_me: PathBuf,
}

impl DirectoryRepository {
    pub fn create_directory(&self, media_path: &str) -> Result<(), DirectoryRepositoryError> {
        let fs_path = self.get_fs_path(media_path);
        if !fs_path.exists() {
            match fs::create_dir(&fs_path) {
                Ok(_) => Ok(()),
                Err(_) => Err(DirectoryRepositoryError::FailedToCreateDirectory),
            }
        } else {
            Err(DirectoryRepositoryError::DirectoryAlreadyExists)
        }
    }

    pub fn get_directory(&self, media_path: &str) -> Option<Directory> {
        let fs_path = self.get_fs_path(media_path);
        match fs::read_dir(&fs_path) {
            Ok(read_dir) => {
                let mut directories: Vec<String> = vec![];
                let mut files: Vec<String> = vec![];

                for entry in read_dir {
                    let entry = &entry.ok()?;
                    let metadata = fs::metadata(entry.path()).ok()?;
                    let name = entry.file_name().clone().into_string().ok()?;
                    if metadata.is_dir() {
                        directories.push(name);
                    } else if metadata.is_file() {
                        files.push(name);
                    }
                }

                let contents: HashMap<String, Vec<String>> = HashMap::from([
                    ("directories".to_owned(), directories),
                    ("files".to_owned(), files),
                ]);

                Some(Directory {
                    media_path: media_path.to_owned(),
                    contents,
                })
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
        let original_dir = self.get_fs_path(media_path);
        let user_root_dir = self.get_fs_path(username);

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
            PathBuf::from("new_directory"),
        ]
        .iter()
        .collect();

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

        // if the username's shared_with_me folder exists, then create a symbolic link
        // to the given folder in that folder, if it does not exist, do the same,
        // but create the directory first

        // share with non existant user, should fail
        // already shared should fail also

        // what should happen if

        // ha mar letezik akkor noveljuk a szamot egyel, az nem jo, inkabb faileljen mer ugy de amugy mukodne
    }

    pub fn rename_directory(&self, media_path: &str, new_name: &str) -> Result<(), ()> {
        // if TO already exists, return error,
        // if FROM does not exists return error
        // replace media_path's last element with new_name and that will be the to
        Ok(())
    }
    pub fn delete_directory(&self, media_path: &str) -> Result<(), DirectoryRepositoryError> {
        // csak siman kitorolni ha letezik, ha nem akkor 404
        // megcsinalni hogy
        let fs_path = self.get_fs_path(media_path);
        // this function does not follow symbolic links, it just deletes the link itself
        // so only the owner can delete shared directories
        if !fs_path.exists() {
            return Err(DirectoryRepositoryError::DirectoryDoesNotExist);
        }

        fs::remove_dir_all(fs_path).or(Err(DirectoryRepositoryError::FailedToDeleteDirectory))
    }
    fn get_fs_path(&self, media_path: &str) -> PathBuf {
        PathBuf::from(format!("{}/{}", self.media_root, media_path))
    }
}
