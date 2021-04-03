import 'dart:async' show Future;
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MaterialApp(
    home: LoadingScreen(),
  ));
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    isLogged(context);
    return Scaffold(
      body: Center(
        child: Icon(
          Icons.hourglass_top_sharp,
        ),
      ),
    );
  }
}

String user;

Future isLogged(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userCheck = await _getUsername().toString();
  String urlCheck = await _getUrl().toString();
  String passwordCheck = await _getPassword().toString();
  print('usercheck - >' + userCheck);
  if (userCheck == null || urlCheck == null || passwordCheck == null) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditSystemSettings()),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<MyApp> {
  String username = '';
  String password = '';
  String url = '';
  String token = '';

  Future<void> getToken() async {
    String oauthUrl = this.url + "API URL";
    var map = new Map();
    map["username"] = this.username;
    map["password"] = this.password;
    map["grant_type"] = "....";
    map["client_id"] = "....";

    String basicAuth = 'Basic ' + base64Encode(utf8.encode("SECURITY INFO"));
    Map parsed = new Map();
    http
        .post(oauthUrl,
            body: map, headers: <String, String>{'authorization': basicAuth})
        .then((resp) => {
              parsed = json.decode(resp.body),
              setState(() {
                this.token = parsed["access_token"];
                _setToken(parsed["access_token"]);
              })
            })
        .catchError((err) => {this.token = "ERROR"});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getUsername().then((v) {
        setState(() {
          username = v;
        });
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getPassword().then((v) {
        setState(() {
          password = v;
        });
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getUrl().then((v) {
        setState(() {
          url = v;
        });
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await this.getToken();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    getToken();
    return Scaffold(
        appBar: AppBar(
          title: Text('BERK-BACALAN APP'),
          centerTitle: true,
          backgroundColor: Colors.grey,
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    child: Image.asset(
                  'images/my_logo.png',
                  height: 300,
                )),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  child: Text(username ?? 'NO USERNAME LOADED.',
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
                SizedBox(
                  height: 20,
                  width: 20,
                ),
                Container(
                    height: 35,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                        ),
                        child: Text('ENTER'),
                        onPressed: () {
                          getToken();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SomethingList()),
                          );
                        })),
                SizedBox(width: 20, height: 20),
                Container(
                    height: 35,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                        child: Text('USER INFO'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ThirdRoute()),
                          );
                        })),
              ],
            )));
  }
}

// ignore: must_be_immutable
class EditSystemSettings extends StatelessWidget {
  String url = '';
  String username = '';
  String password = '';
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController urlController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SYSTEM INFO/EDIT"),
        backgroundColor: Colors.grey,
      ),
      body: new Column(
        children: <Widget>[
          new ListTile(
            leading: const Text(
              "URL : ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            title: new TextField(
              controller: urlController,
              decoration: new InputDecoration(
                hintText: "URL",
              ),
            ),
          ),
          new ListTile(
            leading: const Text(
              "Username : ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            title: new TextField(
              controller: usernameController,
              decoration: new InputDecoration(
                hintText: "Username",
              ),
            ),
          ),
          new ListTile(
            leading: const Text(
              "Password : ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            title: new TextField(
              controller: passwordController,
              decoration: new InputDecoration(
                hintText: "Password",
              ),
            ),
          ),
          const Divider(
            height: 1.0,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,
              ),
              child: Text('Save'),
              onPressed: () {
                if (usernameController.text != '') {
                  _resetUsername();
                  _setUsername(usernameController.text);
                }
                if (passwordController.text != '') {
                  _resetPassword();
                  _setPassword(passwordController.text);
                }
                if (urlController.text != '') {
                  _resetUrl();
                  _setUrl(urlController.text);
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThirdRoute()),
                );
              })
        ],
      ),
    );
  }
}

class ThirdRoute extends StatefulWidget {
  @override
  _ThirdRouteState createState() => _ThirdRouteState();
}

class _ThirdRouteState extends State<ThirdRoute> {
  String username = '';
  String password = '';
  String url = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getUsername().then((v) {
        setState(() {
          username = v;
        });
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getPassword().then((v) {
        setState(() {
          password = v;
        });
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getUrl().then((v) {
        setState(() {
          url = v;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("System Info"), backgroundColor: Colors.grey),
      body: Center(
        child: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              height: 30,
              child: Row(
                children: [
                  Text("Username : ",
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                  Center(
                      child: Text(username ?? 'No username loaded.',
                          style: TextStyle(color: Colors.black, fontSize: 16))),
                ],
              ),
            ),
            Container(
              height: 30,
              child: Row(
                children: [
                  Text("Password : ",
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                  Center(
                      child: Text(password ?? 'No password loaded.',
                          style: TextStyle(color: Colors.black, fontSize: 16))),
                ],
              ),
            ),
            Container(
              height: 30,
              child: Row(
                children: [
                  Text("Url : ",
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                  Center(
                      child: Text(url ?? 'No url loaded.',
                          style: TextStyle(color: Colors.black, fontSize: 16))),
                ],
              ),
            ),
            SizedBox(
              height: 15,
              width: 0,
            ),
            Container(
                height: 35,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: RaisedButton(
                    child: Text('Home'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp()),
                      );
                    })),
            SizedBox(
              height: 15,
              width: 0,
            ),
            Container(
                height: 35,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                // ignore: deprecated_member_use
                child: RaisedButton(
                    child: Text('Edit'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditSystemSettings()),
                      );
                    })),
          ],
        ),
      ),
    );
  }
}

class SomethingList extends StatefulWidget {
  @override
  _SomethingListState createState() => _SomethingListState();
}

class _SomethingListState extends State<SomethingList> {
  String url = '';
  String token = '';
  String test = '';
  int k = 0;
  int x = 0;
  String path = '...';

  @override
  Future<void> initState() {
    super.initState();
    _getUrl().then((v_url) {
      setState(() {
        this.url = v_url;
      });
    });
    _getToken().then((v_token) {
      setState(() {
        this.token = v_token;
      });
    });
    setState(() {
      this.test = '';
      this.k = 0;
    });
    setState(() {
      this.my_saved_data = ['...'];
      this.x = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await this.getSomeData('your path');
      setState(() {});
    });
  }

  List<String> my_saved_data = new List();
  List<String> my_saved_data_names = new List();
  List<String> my_saved_data_id = new List();
  List<String> my_saved_data_path = new List();

  Future<List> getSomeData(path) async {
    http.Response response = await http.get(url + 'api link' + path, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Path': 'your path',
    });
    print('HTML Body :  ' + response.body);
    print('Status Code : ' + response.statusCode.toString());
    this.test = response.statusCode.toString();
    Iterable myList = json.decode(response.body);
    myList.forEach((i) {
      if (i['type'] == 'Object') {
        my_saved_data.add(i['name']);
        my_saved_data_names.add(i['name']);
        my_saved_data_path.add(i['path']);
      }
      if (i['type'] == 'Folder') {
        return getSomeData(i['path']);
      }
      k = k + 1;
    });

    this.my_saved_data = my_saved_data;
    setState(() {
      this.x = my_saved_data.length - 1;
    });
    return my_saved_data;
  }

  var _counter = 0;

  void _gotoSomething(String path) async {
    setState(() {
      _counter++;
    });
    String desiredUrl = this.url +
        "api link" +
        path +
        "&token=" +
        this.token +
        "something.html";
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => MyWebView(
              title: "BERK-BACALAN APP",
              theUrl: desiredUrl,
            )));
  }

  @override
  Widget build(BuildContext context) {
    if (my_saved_data.length == 1) {
      setState(() {
        this.my_saved_data = ['...'];
        this.x = 0;
        getSomeData('/');
      });
    }
    return Scaffold(
      appBar:
          AppBar(title: Text("My Saved Data"), backgroundColor: Colors.grey),
      body: Container(
        child: Center(
          child: ListView(
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                  height: 600,
                  child: Scrollbar(
                    child: Center(
                      child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: x,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              _gotoSomething(my_saved_data_path[index]);
                            },
                            child: Card(
                                child: Center(
                                    child: Text(
                              my_saved_data_names[index],
                              style: TextStyle(fontSize: 16),
                            ))),
                          );
                        },
                      ),
                    ),
                  )),
              SizedBox(width: 20, height: 20),
              Container(
                  height: 35,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: RaisedButton(
                      child: Text('Refresh'),
                      onPressed: () {
                        setState(() {
                          this.my_saved_data = ['...'];
                          this.x = 0;
                          getSomeData('your path');
                        });
                      }))
            ],
          ),
        ),
      ),
    );
  }
}

_getUsername() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('username');
}

_getPassword() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('password').toString();
}

_getUrl() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('url').toString();
}

_setUsername(newUsername) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("username", newUsername);
}

_setPassword(newPassword) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("password", newPassword);
}

_setUrl(newUrl) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("url", newUrl);
}

_getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token').toString();
}

_setToken(newToken) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("token", newToken);
}

_resetUsername() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('username');
}

_resetPassword() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('password');
}

_resetUrl() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('url');
}

class MyWebView extends StatelessWidget {
  final String title;
  final String theUrl;

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  MyWebView({
    @required this.title,
    @required this.theUrl,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.landscapeLeft]);
    print('url ->>> ' + theUrl);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: Text(title),
        ),
        body: WebView(
          initialUrl: theUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
        ));
  }
}
