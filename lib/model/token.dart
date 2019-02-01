class Token {

  //offset is subtracted from expire time
  final expireOffSet = 5;

  String accessToken;
  String tokenType;
  String refreshToken;
  DateTime issueTimeStamp;
  DateTime expireTimeStamp;
  int expiresIn;

  Token();

  factory Token.fromJson(Map<String, dynamic> json) =>
      Token.fromMap(json);

  Map toMap() => Token.toJsonMap(this);

  @override
  String toString() => Token.toJsonMap(this).toString();

  static Map toJsonMap(Token model) {
    Map ret = new Map();
    if (model != null) {
      if (model.accessToken != null) {
        ret["access_token"] = model.accessToken;
      }
      if (model.tokenType != null) {
        ret["token_type"] = model.tokenType;
      }
      if (model.refreshToken != null ) {
        ret["refresh_token"] = model.refreshToken;
      }
      if (model.expiresIn != null ) {
        ret["expires_in"] = model.expiresIn;
      }      
    }
    return ret;
  }

  static Token fromMap(Map map) {
    if (map == null)
      throw new Exception("No token from received");

    if ( map["error"] != null )
      throw new Exception("Error during token request: " + map["error"] + ": " + map["error_description"]);

    Token model = new Token();
    model.accessToken = map["access_token"];
    model.tokenType = map["token_type"];
    model.expiresIn = map["expires_in"];
    model.refreshToken = map["refresh_token"];
    model.issueTimeStamp = new DateTime.now();
    model.expireTimeStamp = model.issueTimeStamp.add(new Duration(seconds: model.expiresIn-model.expireOffSet));
    return model;
  }

  static bool isExpired(Token token) {
    return token.expireTimeStamp.isBefore(new DateTime.now());
  }

  static bool tokenIsValid(Token token) {
    return token != null && !Token.isExpired(token) && token.accessToken != null;
  }
}