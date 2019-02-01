import 'package:flutter/widgets.dart';

class Config {
  String authorizationUrl;
  String tokenUrl;
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final String responseType;
  final String contentType;
  final String scope;
  final String liferayServer;
  Size screenSize;

  Config(this.liferayServer, this.redirectUri, this.clientId, this.clientSecret,
      { this.scope,
        this.responseType = "code",
        this.contentType = "application/x-www-form-urlencoded",
        this.screenSize}) {
    this.authorizationUrl =
        this.liferayServer+"/o/oauth2/authorize";
    this.tokenUrl =
        this.liferayServer+"/o/oauth2/token";
  }
}