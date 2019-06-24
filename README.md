# Flutter Liferay OAuth 2.0

A Flutter OAuth package for performing Liferay login using OAuth2 standard to access Liferay DXP JAX-RS service. 
Forked from [Earlybyte.aad_oauth](https://github.com/Earlybyte/aad_oauth).

Supported Flows:
 - [Authorization code flow (including refresh token flow)](https://dev.liferay.com/discover/deployment/-/knowledge_base/7-1/authorizing-account-access-with-oauth2)
 - [PKCE Extended Authorization Code flow](https://portal.liferay.dev/docs/7-1/deploy/-/knowledge_base/d/authorizing-account-access-with-oauth2#pkce-extended-authorization-code-flow)

More info on [Liferay/Oauth2](https://dev.liferay.com/discover/deployment/-/knowledge_base/7-1/oauth-2-0)

## Usage

Create a Liferay JAX-RS service and configure OAUTH 2.0 by following these [instructions](https://dev.liferay.com/develop/tutorials/-/knowledge_base/7-1/jax-rs) 

In the flutter app, initialize:

```dart
final Config config = new Config(
  "<LIFERAY SERVER>",
  "<REDIRECT_URL>",
  "<CLIENT_ID>",
  usePkce: true); // Request an authorization code using PKCE code challenge.
final LiferayOAuth oauth = new LiferayOAuth(config);
```

This allows you to pass in an Liferay Server, Redirect Url, client ID, Client secret and few more optional params.

If your service require to pass an oauth2 scope, the config allows for an optional param 'scope'. 
For more on [OAuth2 Scopes](https://dev.liferay.com/discover/deployment/-/knowledge_base/7-1/oauth2-scopes)

Then once you have an OAuth instance, you can call `login()` and afterwards `getAccessToken()` to 
retrieve an access token and pass it to the rest client:

```dart
await oauth.login();
String accessToken = await oauth.getAccessToken();
```

You can also call `getAccessToken()` directly. It will automatically login and retrieve an access token.

Tokens are cached in-memory. To destroy the tokens you can call `logout()`:

## Installation

Add the following to your pubspec.yaml dependencies:

```yaml
dependencies:
  flutter_liferay_oauth: "^0.1.3"
```
