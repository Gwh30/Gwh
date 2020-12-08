import 'package:flutter/material.dart';
import 'package:trackundemo/datalist.dart';
import 'package:trackundemo/drawer.dart';
import 'package:trackundemo/home.dart';
import 'package:trackundemo/page/detail.dart';
import 'package:trackundemo/page/mixpage.dart';
import 'package:trackundemo/page/routelist.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _IndexState();
  }
}

class _IndexState extends State<IndexPage> {
  final List<BottomNavigationBarItem> bottomNavItems = [
    BottomNavigationBarItem(
      backgroundColor: Colors.blue,
      icon: Icon(Icons.home),
      title: Text("地図のみ"),
    ),
    BottomNavigationBarItem(
      backgroundColor: Colors.blue,
      icon: Icon(Icons.message),
      title: Text("リストのみ"),
    ),
    BottomNavigationBarItem(
      backgroundColor: Colors.blue,
      icon: Icon(Icons.shopping_cart),
      title: Text("ミックス"),
    ),
  ];

  int currentIndex;

  final pages = [HomePage(), DataList(), MixPage()];

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
  }

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
              Builder(builder: (context) {
                return IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return RouteList();
                      }),
                    );
                  },
                );
              })
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
                header,
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
              ],
            ),
          ),
        ),
      );
  Widget header = DrawerHeader(
    padding: EdgeInsets.zero,
    /* padding置为0 */
    child: new Stack(children: <Widget>[
      /* 用stack来放背景图片 */
      new Image.asset(
        'images/p_h_r_600.png',
        fit: BoxFit.fill,
        width: double.infinity,
      ),
      new Align(
        /* 先放置对齐 */
        alignment: FractionalOffset.bottomLeft,
        child: Container(
          height: 70.0,
          margin: EdgeInsets.only(left: 12.0, bottom: 12.0),
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            /* 宽度只用包住子组件即可 */
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new CircleAvatar(
                backgroundImage: AssetImage('images/pic1.jpg'),
                radius: 35.0,
              ),
              new Container(
                margin: EdgeInsets.only(left: 6.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 水平方向左对齐
                  mainAxisAlignment: MainAxisAlignment.center, // 竖直方向居中
                  children: <Widget>[
                    new Text(
                      "i-test",
                      style: new TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.blue),
                    ),
                    new Text(
                      "username",
                      style: new TextStyle(fontSize: 14.0, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ]),
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
