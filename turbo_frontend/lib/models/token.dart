class AccessToken {
  String accessToken;

  AccessToken(this.accessToken);

  AccessToken.fromJson(Map<String, dynamic> json) : accessToken = json['token'];
}
