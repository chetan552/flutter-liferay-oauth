import 'dart:async';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'request/authorization_request.dart';
import 'model/config.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class RequestCode {
  final StreamController<String> _onCodeListener = new StreamController();
  final FlutterWebviewPlugin _webView = new FlutterWebviewPlugin();
  final Config _config;
  AuthorizationRequest _authorizationRequest;

  var _onCodeStream;
  
  RequestCode(Config config) : _config = config {
    _authorizationRequest = new AuthorizationRequest(config);
  }

  Future<String> requestCode() async {
    var code;
    final String urlParams = _constructUrlParams();
    
    // workaround for webview overlapping statusbar
    // if we have a screen size use it to adjust the webview
    await _webView.launch(
        "${_authorizationRequest.url}?$urlParams",
        clearCookies: _authorizationRequest.clearCookies, 
        hidden: false,
        rect: _config.screenSize != null ?
          (_config.screenSize.height > 0 && _config.screenSize.width > 0) ? Rect.fromLTWH(
          0.0,
          100.0,
          _config.screenSize.width,
          _config.screenSize.height-150) : null
        : null
    );


    _webView.onStateChanged.listen((WebViewStateChanged change) {
        if ( change.type.index == 2)
          _webView.show();
    });

    _webView.onUrlChanged.listen((String url) {
        String uriWithOutParams = url;

        if (url.contains('?')) {
          uriWithOutParams = url.substring(0, url.lastIndexOf('?'));
        }

        if (uriWithOutParams == _authorizationRequest.redirectUrl) {
          Uri uri = Uri.parse(url);
          _onCodeListener.add(uri.queryParameters["code"]);
        }
    });

    code = await _onCode.first;
    await _webView.close();

    return code;
  }

  Future<void> clearCookies() async {
    await _webView.launch("", hidden: true, clearCookies: true);
    await _webView.close();
  }

  Stream<String> get _onCode =>
      _onCodeStream ??= _onCodeListener.stream.asBroadcastStream();

  String _constructUrlParams() => _mapToQueryParams(_authorizationRequest.parameters);

  String _mapToQueryParams(Map<String, String> params) {
    final queryParams = <String>[];
    params
        .forEach((String key, String value) => queryParams.add("$key=$value"));
    return queryParams.join("&");
  }

}