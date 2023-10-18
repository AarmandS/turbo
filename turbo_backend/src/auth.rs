use std::{
    future::{ready, Ready},
    sync::Arc,
};

use actix_web::{
    dev::Payload, error::ErrorUnauthorized, http, web::Data, Error, FromRequest, HttpRequest,
};
use chrono::{Duration, Utc};
use jsonwebtoken::{decode, encode, Algorithm, DecodingKey, EncodingKey, Validation};
use serde::{Deserialize, Serialize};

use crate::state::{app_state::AppState, test_state::TestState};

pub struct JwtKeys {
    pub encoding_key: EncodingKey,
    pub decoding_key: DecodingKey,
}

#[derive(Debug, Serialize, Deserialize)]
struct Claims {
    sub: String,
    exp: i64,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct AuthenticationToken {
    pub sub: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct TokenResponse {
    pub token: String,
}

impl FromRequest for AuthenticationToken {
    type Error = Error;
    type Future = Ready<Result<Self, Self::Error>>;

    fn from_request(request: &HttpRequest, _: &mut Payload) -> Self::Future {
        let auth_header = request.headers().get(http::header::AUTHORIZATION);

        let auth_token = match auth_header {
            Some(auth_token) => match auth_token.to_str() {
                Ok(auth_token) => auth_token,
                Err(_) => return ready(Err(ErrorUnauthorized("Unauthorized."))),
            },
            None => return ready(Err(ErrorUnauthorized("Unauthorized."))),
        };
        // use box for the state
        let decoding_key = &request
            .app_data::<Data<Arc<dyn AppState + Sync + Send>>>()
            .expect("Could not get app data.")
            .get_jwt_keys()
            .decoding_key;

        let token_data =
            decode::<Claims>(auth_token, decoding_key, &Validation::new(Algorithm::HS256));

        match token_data {
            Ok(token_data) => ready(Ok(AuthenticationToken {
                sub: token_data.claims.sub,
            })),
            Err(_) => ready(Err(ErrorUnauthorized("Unauthorized."))),
        }
    }
}

pub fn get_token(username: &str, encoding_key: &EncodingKey) -> String {
    let duration = 60 * 60 * 24;

    let claims = Claims {
        sub: username.to_owned(),
        exp: (Utc::now() + Duration::seconds(duration)).timestamp() as i64,
    };
    let token = encode(&jsonwebtoken::Header::default(), &claims, encoding_key).unwrap();

    token
}

// media_path should not contain leading slash
pub fn user_has_permission(username: &str, media_path: &str) -> bool {
    let media_path_split: Vec<_> = media_path.split("/").collect();
    let media_path_first_element = media_path_split.first();
    if media_path_first_element.is_none() {
        false
    } else {
        media_path_first_element.unwrap() == &username
    }
}

#[cfg(test)]
mod tests {
    use super::user_has_permission;

    #[test]
    fn test_user_has_permission() {
        // Test when the first element in media_path matches the username
        assert!(user_has_permission("alice", "alice/photos/pic1.jpg"));
        assert!(user_has_permission("bob", "bob/videos/video.mp4"));

        // Test when the first element in media_path doesn't match the username
        assert!(!user_has_permission("charlie", "dave/photos/pic1.jpg"));
        assert!(!user_has_permission("eve", "mallory/videos/video.mp4"));

        // Test when media_path is just a single username
        assert!(user_has_permission("george", "george"));
    }
}
