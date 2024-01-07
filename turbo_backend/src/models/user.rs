use std::path::Path;

use mongodb::bson::oid::ObjectId;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct User {
    #[serde(rename = "_id", skip_serializing_if = "Option::is_none")]
    pub id: Option<ObjectId>,
    pub username: String,
    pub password: String,
}

pub struct UserInfo {
    pub username: String,
    pub space_taken: u128,
    pub files_uploaded: u64,
    // pub profile_picture: Path,
}
