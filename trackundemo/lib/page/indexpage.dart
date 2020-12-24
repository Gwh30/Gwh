import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackundemo/datalist.dart';
import 'package:trackundemo/drawer.dart';
import 'package:trackundemo/home.dart';
import 'package:trackundemo/login.dart';
import 'package:trackundemo/page/detail/detail.dart';
import 'package:trackundemo/page/mixpage.dart';
import 'package:trackundemo/util/http.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _IndexState();
}

class _IndexState extends State<IndexPage> {
  Map map = {};
  String name;
  String username;
  Future _getUserdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    RequestOptions requestOptions =
        new RequestOptions(baseUrl: 'https://demo.trackun.jp', extra: {
      'context': context,
    }, headers: {
      'Authorization': 'Bearer ${token}',
      'Content-Type': 'application/json;charset=utf-8',
    });
    CancelToken cancelToken;

    var response = await HttpUtil().get(
      '/v1.0/user/info',
      options: requestOptions,
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200) {
      setState(() {
        map = json.decode(response.data)['userInfo'];
      });
    } else {
      print('Error${response.statusCode}');
    }
    prefs.setString('name', map['username']);
    prefs.setString('username', map['lastName'] + map['firstName']);
    name = prefs.getString('name');
    username = prefs.getString('username');
  }

  @override
  void initState() {
    super.initState();
    _getUserdata();
    currentIndex = 0;
  }

  Future loginout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return LoginPage();
      },
    ));
  }

  final List<BottomNavigationBarItem> bottomNavItems = [
    BottomNavigationBarItem(
      backgroundColor: Colors.blue,
      icon: Icon(Icons.room),
      title: Text("地図のみ"),
    ),
    BottomNavigationBarItem(
      backgroundColor: Colors.blue,
      icon: Icon(Icons.list),
      title: Text("リストのみ"),
    ),
    BottomNavigationBarItem(
      backgroundColor: Colors.blue,
      icon: Icon(Icons.art_track),
      title: Text("ミックス"),
    ),
  ];

  int currentIndex;

  final pages = [HomePage(), DataList(), MixPage()];

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            title: Text("ドラッカー"),
            backgroundColor: Colors.blue[700],
            actions: <Widget>[
              new PopupMenuButton(
                onSelected: (value) {
                  setState(() {
                    value = value;
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                  new PopupMenuItem(
                    child: new GestureDetector(
                      child: new Text("ログアウト"),
                      onTap: () => loginout(),
                    ),
                  ),
                  new PopupMenuItem(
                    child: new GestureDetector(
                      child: new Text("ユーザー情報修正"),
                    ),
                  ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: bottomNavItems,
            currentIndex: currentIndex,
            type: BottomNavigationBarType.shifting,
            onTap: (index) {
              _changePage(index);
            },
          ),
          body: pages[currentIndex],
          drawer: SmartDrawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text('$name'),
                  accountEmail: Text('$username'),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage('lib/images/avatar.jpg'),
                  ),
                ),
                ListTile(
                  title: Text('ドラッカー追跡'),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return HomePage();
                    }));
                  },
                ),
                Divider(),
                ListTile(
                  title: Text('デバイス管理'),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return Detail();
                    }));
                  },
                ),
                Divider(),
              ],
            ),
          ),
        ),
      );

  /*切换页面*/
  void _changePage(int index) {
    /*如果点击的导航项不是当前项  切换 */
    if (index != currentIndex) {
      setState(() {
        currentIndex = index;
      });
    }
  }
}
