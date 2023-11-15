use mongodb::bson::oid::ObjectId;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::fs;

use super::media_file::MediaFile;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Directory {
    pub media_path: String,
    pub directories: Vec<String>,
    pub images: Vec<MediaFile>,
    pub videos: Vec<MediaFile>,
}

impl Directory {
    pub fn new(media_path: String) -> Self {
        Directory {
            media_path,
            directories: vec![],
            images: vec![],
            videos: vec![],
        }
    }
}

#[derive(Deserialize)]
pub struct DirectoryShare {
    pub media_path: String,
    pub username: String,
}

#[derive(Deserialize)]
pub struct DirectoryRename {
    pub new_name: String,
}
