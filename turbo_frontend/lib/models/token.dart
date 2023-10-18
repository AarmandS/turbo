class AccessToken {
  String accessToken;
  // String tokenType; // why was this here in the first place

  AccessToken.fromJson(Map<String, dynamic> json) : accessToken = json['token'];
  // tokenType = json['token_type'];
  // exp time
}
