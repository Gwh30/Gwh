import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trackundemo/page/indexpage.dart';
import 'package:trackundemo/page/login/dologin.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // TODO: Add text editing controllers (101)
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  handlelogin() async {
    Map params = {
      "grant_type": "password",
      "client_id": "trackun",
      "username": _usernameController.value.text,
      "password": _passwordController.value.text,
    };
    params = new Map<String, dynamic>.from(params);
    var res = await DoLogin.login(data: params);
    Map user;
    if (res.statusCode == 200) {
      user = json.decode(res.data);
      print('登录成功');
      String token = user['access_token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
    } else {
      print('Error${res.statusCode}');
    }
    Navigator.of(context).pop();
    Navigator.push(context, CupertinoPageRoute(
      builder: (context) {
        return IndexPage();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Image.asset('lib/images/title.png'),
                SizedBox(height: 16.0),
                Text('Tracker'),
              ],
            ),
            SizedBox(height: 120.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: Text('CANCEL'),
                  onPressed: () {
                    _usernameController.clear();
                    _passwordController.clear();
                  },
                ),
                RaisedButton(
                  child: Text('NEXT'),
                  onPressed: () => handlelogin(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
