use std::{
    ffi::OsStr,
    path::{Path, PathBuf},
};

pub enum FileType {
    Video,
    Image,
    Unknown,
}

pub fn concat_paths(first: &str, second: &str) -> PathBuf {
    PathBuf::from(format!("{}/{}", first, second))
}

pub fn get_file_type(filename: &str) -> FileType {
    // these should be class varaibles
    let image_extensions: Vec<&OsStr> = vec![OsStr::new("jpg"), OsStr::new("png")];
    let video_extensions: Vec<&OsStr> = vec![OsStr::new("mp4")];

    if let Some(extension) = Path::new(filename).extension() {
        if video_extensions.contains(&extension) {
            FileType::Video
        } else if image_extensions.contains(&extension) {
            FileType::Image
        } else {
            FileType::Unknown
        }
    } else {
        FileType::Unknown
    }
}

pub fn replace_last_path_element(path: &str, new_element: &str) -> String {
    // Find the last occurrence of '/' in the string slice
    if let Some(last_slash_index) = path.rfind('/') {
        // Create a new string with the updated path
        let mut new_path = path[..last_slash_index + 1].to_string();
        new_path.push_str(new_element);
        new_path
    } else {
        // If there's no '/', simply replace the entire path with the new element
        new_element.to_string()
    }
}

pub fn get_last_path_element(path: &str) -> String {
    if let Some(last_slash_index) = path.rfind('/') {
        path[last_slash_index + 1..].to_string()
    } else {
        path.to_owned()
    }
}
