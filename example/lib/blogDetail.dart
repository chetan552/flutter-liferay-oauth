import 'package:flutter/material.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';
import 'restClient.dart' as restClient;
import 'package:flutter_liferay_oauth/flutter_liferay_oauth.dart';
import 'liferayConfig.dart';

class BlogDetailWidget extends StatefulWidget {
  final int blogId;
  final LiferayOAuth oauth;

  BlogDetailWidget(this.blogId, this.oauth) {
    if (blogId == null) {
      throw new ArgumentError("blogId of MemberWidget cannot be null. "
          "Received: '$blogId'");
    }
  }

  @override
  createState() => new BlogDetailState(blogId, oauth);
}

class BlogDetailState extends State<BlogDetailWidget> {
  final int blogId;
  final LiferayOAuth oauth;

  BlogDetailState(this.blogId, this.oauth);

  var data;

  Future getData() async {
    var localData;

    var response = await restClient.getBlogDetail(blogId.toString(), oauth);

    localData = await json.decode(response.body);

    setBlogState(localData);

    return "Success!";
  }

  setBlogState(localData) {
    this.setState(() {
      data = localData;
    });
  }

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  final f = new DateFormat('yyyy-MM-dd hh:mm');

  @override
  Widget build(BuildContext context) {
    Widget titleSection = Container(
        padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 32.0),
        child: data == null
            ? const Center(child: const CircularProgressIndicator())
            : new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    new Text(
                      f.format(new DateTime.fromMillisecondsSinceEpoch(
                          int.parse(data["createdDate"]))),
                      style: TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 15.0,
                      ),
                    ),
                    new Text(
                      data["title"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0,
                      ),
                    ),
                  ]));

    Widget dateSection = Container(
      padding: const EdgeInsets.all(1.0),
      child: data == null
          ? const Center(child: const CircularProgressIndicator())
          : new Text(
              f.format(new DateTime.fromMillisecondsSinceEpoch(
                  int.parse(data["createdDate"]))),
              style: TextStyle(
                color: Color(0xFF757575),
                fontSize: 15.0,
              ),
            ),
    );

    Widget textSection = Container(
      padding: const EdgeInsets.all(20.0),
      child: data == null
          ? const Center(child: const CircularProgressIndicator())
          : SizedBox(
              height: 300.0,
              child: new Center(
                child: HtmlView(data: data["content"]),
              )),
    );

    return new Scaffold(
      appBar: new AppBar(
        title: data == null
            ? const Center(child: const CircularProgressIndicator())
            : new Text(data["title"]),
      ),
      body: data == null
          ? const Center(child: const CircularProgressIndicator())
          : ListView(
              shrinkWrap: true,
              children: [
                Image.network(
                  LiferayConfig.server + data["imageUrl"],
                  width: 600.0,
                  height: 240.0,
                  fit: BoxFit.cover,
                ),
                titleSection,
                textSection,
              ],
            ),
    );
  }
}
