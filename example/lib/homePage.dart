import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'restClient.dart' as restClient;
import 'blogDetail.dart';
import 'package:flutter_liferay_oauth/model/config.dart';
import 'liferayConfig.dart';
import 'package:flutter_liferay_oauth/flutter_liferay_oauth.dart';

class HomePageWidget extends StatefulWidget {
  HomePageWidget({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<HomePageWidget> {
  var data;

  static final Config config = new Config(
      LiferayConfig.server, LiferayConfig.redirectUrl, LiferayConfig.clientId,
      LiferayConfig.clientSecret);
  final LiferayOAuth oauth = LiferayOAuth(config);

  //Navigation to blog detail page
  _pushMember(int blogId) {
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) => new BlogDetailWidget(blogId, oauth)));
  }

  void showMessage(String text) {
    var alert = new AlertDialog(content: new Text(text), actions: <Widget>[
      new FlatButton(
          child: const Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void showError(dynamic ex) {
    showMessage(ex.toString());
  }

  void getData() async {
    String accessToken;
    try {
      await oauth.login();
      accessToken = await oauth.getAccessToken();
    } catch (ex) {
      showError(ex);
    }

    var response = await restClient.getAllBlogs(oauth);

    var localData = json.decode(response.body);

    this.setState(() {
      data = localData;
    });

    //return "Success!";
  }

  @override
  void initState() {
    super.initState();

    //this.getData();
  }

  final f = new DateFormat('yyyy-MM-dd hh:mm');

  @override
  Widget build(BuildContext context) {
    oauth.setWebViewScreenSize(MediaQuery.of(context).size);
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("FLutter/Liferay blogs demo"),
      ),
      body: new Column(children: <Widget>[
        new Padding(
          padding: new EdgeInsets.all(0.0),
          child: new PhysicalModel(
            color: Colors.white,
            elevation: 3.0,
          ),
        ),
        new Expanded(
          child: data == null
              ? //const Center(child: const CircularProgressIndicator())
                Center(
                  child:new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new RaisedButton(
                            padding: const EdgeInsets.all(8.0),
                            textColor: Colors.white,

                            color: Colors.blue,
                            onPressed: getData,
                            child: new Text("Signin with Liferay"),
                          ),
                      ]))
              : data["list"].length != 0
                  ? new ListView.builder(
                      shrinkWrap: true,
                      itemCount: data == null ? 0 : data["list"].length,
                      padding: new EdgeInsets.all(8.0),
                      itemBuilder: (BuildContext context, int index) {
                        return new Card(
                          elevation: 1.7,
                          child: new Padding(
                            padding: new EdgeInsets.all(10.0),
                            child: new Column(
                              children: [
                                new Row(
                                  children: <Widget>[
                                    new Padding(
                                      padding: new EdgeInsets.only(left: 4.0),
                                      child: new Text(
                                        timeago.format(DateTime.parse(
                                            data["list"][index]
                                                ["createdDate"])),
                                        style: new TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    new Padding(
                                      padding: new EdgeInsets.all(5.0),
                                      child: new Text(
                                        data["list"][index]["title"],
                                        style: new TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                new Row(
                                  children: [
                                    new Expanded(
                                      child: new GestureDetector(
                                        child: new Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            new Padding(
                                              padding: new EdgeInsets.only(
                                                  left: 4.0,
                                                  right: 8.0,
                                                  bottom: 8.0,
                                                  top: 8.0),
                                              child: new Text(
                                                data["list"][index]["title"],
                                                style: new TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            new Padding(
                                                padding: new EdgeInsets.only(
                                                    left: 4.0,
                                                    right: 4.0,
                                                    bottom: 4.0),
                                                child: new Text(
                                                  data["list"][index]
                                                      ["content"],
                                                )),
                                          ],
                                        ),
                                        onTap: () {
                                          _pushMember(
                                              data["list"][index]["id"]);
                                        },
                                      ),
                                    ),
                                    new Column(
                                      children: <Widget>[
                                        new Padding(
                                          padding:
                                              new EdgeInsets.only(top: 8.0),
                                          child: new SizedBox(
                                            height: 100.0,
                                            width: 100.0,
                                            child: new Image.network(
                                              LiferayConfig.server + data["list"][index]["imageUrl"],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ), ////
                          ),
                        );
                      },
                    )
                  : new Center(),
        )
      ]),
    );
  }
}
