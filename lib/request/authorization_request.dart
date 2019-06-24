import '../model/config.dart';

class AuthorizationRequest {
  String url;
  String redirectUrl;
  Map<String, String> parameters;
  Map<String, String> headers;
  bool fullScreen;
  bool clearCookies;
  String verifier;

  AuthorizationRequest(Config config,
      {bool fullScreen: true, bool clearCookies: false}) {
    this.url = config.authorizationUrl;
    this.redirectUrl = config.redirectUri;
    this.parameters = {
      "client_id": config.clientId,
      "response_type": config.responseType,
      "redirect_uri": config.redirectUri
    };

    if ( config.scope != null ) {
      parameters.putIfAbsent("scope", () => config.scope);
    }

    this.fullScreen = fullScreen;
    this.clearCookies = clearCookies;
  }
}
