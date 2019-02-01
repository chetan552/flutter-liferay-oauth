import 'package:http/http.dart' as http;
import 'dart:io';
import 'liferayConfig.dart';


/// A file in which the users credentials are stored persistently. If the server
/// issues a refresh token allowing the client to refresh outdated credentials,
/// these may be valid indefinitely, meaning the user never has to
/// re-authenticate.
final credentialsFile = new File("~/.myblogs/credentials.json");

getAllBlogs(oauth) async {
  var accessToken = await oauth.getAccessToken();
  var response = await http
      .get(Uri.encodeFull(LiferayConfig.server +'/o/blogs/all'), headers: {
    "Authorization":
    "Bearer " + accessToken
  });

  return response;
}

getBlogDetail(blogId, oauth) async {
  var accessToken = await oauth.getAccessToken();
  var response = await http
      .get(Uri.encodeFull(LiferayConfig.server +'/o/blogs/'+ blogId), headers: {
  "Authorization":
  "Bearer " + accessToken
  });

  return response;
}