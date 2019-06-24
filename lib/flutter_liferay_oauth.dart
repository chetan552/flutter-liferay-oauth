library flutter_liferay_oauth;

import 'model/config.dart';
import 'package:flutter/material.dart';
import 'helper/auth_storage.dart';
import 'model/token.dart';
import 'request_code.dart';
import 'request_token.dart';
import 'dart:async';
import 'dart:math';

class LiferayOAuth {
  static Config _config;
  AuthStorage _authStorage;
  Token _token;
  RequestCode _requestCode;
  RequestToken _requestToken;
  String _codeVerifier;

  factory LiferayOAuth(config) {
    if (LiferayOAuth._instance == null)
      LiferayOAuth._instance = new LiferayOAuth._internal(config);
    return _instance;
  }

  static LiferayOAuth _instance;

  LiferayOAuth._internal(config) {
    LiferayOAuth._config = config;
    _authStorage = _authStorage ?? new AuthStorage();
    _requestCode = new RequestCode(_config);
    _requestToken = new RequestToken(_config);
  }

  void setWebViewScreenSize(Size screenSize) {
    _config.screenSize = screenSize;
  }

  Future<void> login() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();
  }

  Future<String> getAccessToken() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token.accessToken;
  }

  bool tokenIsValid() {
    return Token.tokenIsValid(_token);
  }

  Future<void> logout() async {
    await _authStorage.clear();
    await _requestCode.clearCookies();
    _token = null;
    LiferayOAuth(_config);
  }

  Future<void> _performAuthorization() async {
    // load token from cache
    _token = await _authStorage.loadTokenToCache();

    if (_config.usePkce) {
      _codeVerifier = await _authStorage.loadCodeVerifierFromCache();

      if (_codeVerifier == null) {
        _codeVerifier = _generateCodeVerifier();
      }
    }

    //still have refresh token / try to get new access token with refresh token
    if (_token != null)
      await _performRefreshAuthFlow();

    // if we have no refresh token try to perform full request code oauth flow
    else {
      try {
        await _performFullAuthFlow();
      } catch (e) {
        rethrow;
      }
    }

    //save token to cache
    await _authStorage.saveTokenToCache(_token);

    //save codeverifier
    await _authStorage.saveCodeVerifierToCache(_codeVerifier);
  }

  Future<void> _performFullAuthFlow() async {
    String code;
    try {
      code = await _requestCode.requestCode(_codeVerifier);
      _token = await _requestToken.requestToken(code,_codeVerifier);
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<void> _performRefreshAuthFlow() async {
    if (_token.refreshToken != null) {
      try {
        _token = await _requestToken.requestRefreshToken(_token.refreshToken, _codeVerifier);
      } catch (e) {
        //do nothing (because later we try to do a full oauth code flow request)
      }
    }
  }

  String _generateCodeVerifier() {
    final Random _random = Random.secure();
    int length = 50;
    String text = "";
    String allowed = "-._~ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    for (var i = 0; i < length; i++) {
      text += allowed[_random.nextInt(allowed.length-1)];
    }

    return text;
  }
}
