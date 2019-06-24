import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'model/config.dart';
import 'request/token_refresh_request.dart';
import 'request/token_request.dart';
import 'model/token.dart';

class RequestToken {
  final Config config;
  TokenRequestDetails _tokenRequest;
  TokenRefreshRequestDetails _tokenRefreshRequest;
  String _codeVerifier;

  RequestToken(this.config);

  Future<Token> requestToken(String code, String codeVerifier) async {
    _codeVerifier = codeVerifier;
    _generateTokenRequest(code);
    return await _sendTokenRequest(_tokenRequest.params, _tokenRequest.headers);
  }

  Future<Token> requestRefreshToken(String refreshToken, String codeVerifier) async {
    _codeVerifier = codeVerifier;
    _generateTokenRefreshRequest(refreshToken);
    return await _sendTokenRequest(
        _tokenRefreshRequest.params, _tokenRefreshRequest.headers);
  }

  Future<Token> _sendTokenRequest(
      Map<String, String> params, Map<String, String> headers) async {

    if (config.usePkce) {
      params.putIfAbsent("code_verifier", () => _codeVerifier);
    }

    Response response =
        await post("${_tokenRequest.url}", body: params, headers: headers);
    Map<String, dynamic> tokenJson = json.decode(response.body);
    Token token = new Token.fromJson(tokenJson);
    return token;
  }

  void _generateTokenRequest(String code) {
    _tokenRequest = new TokenRequestDetails(config, code);
  }

  void _generateTokenRefreshRequest(String refreshToken) {
    _tokenRefreshRequest = new TokenRefreshRequestDetails(config, refreshToken);
  }
}
