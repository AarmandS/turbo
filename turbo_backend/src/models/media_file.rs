use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct MediaFile {
    pub thumbnail: String,
    pub full_size: String,
}
