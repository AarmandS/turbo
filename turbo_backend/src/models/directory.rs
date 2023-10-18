use mongodb::bson::oid::ObjectId;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::fs;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Directory {
    pub media_path: String,
    pub contents: HashMap<String, Vec<String>>,
}

#[derive(Deserialize)]
pub struct DirectoryShare {
    pub media_path: String,
    pub username: String,
}
