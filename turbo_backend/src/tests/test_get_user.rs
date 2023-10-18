// use std::sync::Arc;

// use actix_web::{
//     http, test,
//     web::{self, Data},
//     App,
// };
// use serde_json::json;

// use crate::{
//     api::user_endpoints::{create_user, get_user},
//     state::{app_state::AppState, test_state::TestState},
// };

// #[actix_web::test]
// async fn test_get_user_after_create() {
//     let app_state: Data<Arc<dyn AppState + Sync + Send>> =
//         Data::new(Arc::new(TestState::new().await) as Arc<dyn AppState + Sync + Send>);
//     let app = test::init_service(
//         App::new()
//             .app_data(app_state)
//             .route("/users", web::post().to(create_user))
//             .route("/users/{username}", web::get().to(get_user)),
//     )
//     .await;

//     let request_data = json!({
//         "username": "test",
//         "password": "password"
//     });

//     let request = test::TestRequest::post()
//         .uri("/users")
//         .insert_header((http::header::CONTENT_TYPE, "application/json"))
//         .set_payload(request_data.to_string())
//         .to_request();

//     let response = test::call_service(&app, request).await;

//     assert_eq!(response.status(), 201);

//     let request = test::TestRequest::get().uri("/users/test").to_request();
//     let response = test::call_service(&app, request).await;

//     assert_eq!(response.status(), 200);
// }

// #[actix_web::test]
// async fn test_get_user_does_not_exist() {
//     let app_state: Data<Arc<dyn AppState + Sync + Send>> =
//         Data::new(Arc::new(TestState::new().await) as Arc<dyn AppState + Sync + Send>);
//     let app = test::init_service(
//         App::new()
//             .app_data(app_state)
//             .route("/users/{username}", web::get().to(get_user)),
//     )
//     .await;

//     let request = test::TestRequest::get().uri("/users/test").to_request();
//     let response = test::call_service(&app, request).await;

//     assert_eq!(response.status(), 404);
// }
