import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trackundemo/util/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackundemo/util/http.dart';

class Detail extends StatefulWidget {
  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  var _checkValue = false;
  bool check = false;
  List<bool> _checkValues = [];
  bool _switchValue1 = false;
  List<bool> _switchValue1list = [];
  bool _switchValue2 = false;
  List<bool> _switchValue2list = [];
  List list = [];
  String version;
  Map map = {};
  Future _detail() async {
    var data = {
      'pageSize': '100',
      'pageNumber': '1',
    };

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
      '/v1.0/deviceBinding/list?pageSize=100&pageNumber=1',
      data: data,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200) {
      setState(() {
        list = json.decode(response.data)['list'];
        prefs.setInt('num', list.length);
        print(prefs.getInt('num'));
        for (int i = 0; i < list.length; i++) {
          prefs.setString('version' + i.toString(), list[i]["firmwareVersion"]);
        }
      });
    } else {
      print('Error${response.statusCode}');
    }
    for (int i = 0; i < list.length; i++) {
      _checkValues.add(false);
      _switchValue1list.add(true);
      _switchValue2list.add(true);
    }
  }

  Map lmap = {};
  String imei;
  int index;
  Future getUpdata(index, imei) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    version = prefs.getString('version' + index.toString());
    String token = prefs.getString('token');
    var data = {'currentVersion': '$version', 'canTestVersion': 'true'};
    RequestOptions requestOptions =
        new RequestOptions(baseUrl: 'https://demo.trackun.jp', extra: {
      'context': context,
    }, headers: {
      'Authorization': 'Bearer ${token}',
      'Content-Type': 'application/json;charset=utf-8',
    });
    CancelToken cancelToken;
    var response = await HttpUtil().get(
      '/v1.0/version/updateTarget?currentVersion=$version&canTestVersion=true',
      data: data,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200) {
      setState(() {
        map = json.decode(response.data);
        if (map["errorMessage"] == null) {
          print("no");
        } else {
          Fluttertoast.showToast(
            msg: "更新できるバージョンがございません",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
          );
        }
      });
    } else {
      print('Error${response.statusCode}');
    }
    var ldata = {
      'pageSize': '1',
      'pageNumber': '1',
      'status': '1',
      'imei': '$imei',
    };
    var lresponse = await HttpUtil().get(
      '/v1.0/deviceVersion/list?pageSize=1&pageNumber=1&status=1&imei=862211044198620',
      data: ldata,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    if (lresponse.statusCode == 200) {
      setState(() {
        lmap = json.decode(lresponse.data);
      });
    } else {
      print('Error${lresponse.statusCode}');
    }
  }

  Future deleteData() async {
    var data = {
      "type": 8,
      "imeis": [],
    };
  }

  @override
  void initState() {
    super.initState();
    _detail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("デバイス管理"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            height: 50,
            child: ButtonBar(
              children: <Widget>[
                RaisedButton(
                  child: Text("登録"),
                  onPressed: () {
                    return showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: Text(
                                "デバイス登録",
                                style: TextStyle(fontSize: 20.0),
                              ),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  // padding:
                                  //     EdgeInsets.symmetric(horizontal: 24.0),
                                  children: <Widget>[
                                    TextField(
                                      controller: TextEditingController(),
                                      decoration: InputDecoration(
                                        filled: true,
                                        labelText: 'デバイスのimei番号を記入してください',
                                      ),
                                    ),
                                    TextField(
                                      controller: TextEditingController(),
                                      decoration: InputDecoration(
                                        filled: true,
                                        labelText: 'デバイスのiccid番号を記入してください',
                                      ),
                                    ),
                                    TextField(
                                      controller: TextEditingController(),
                                      decoration: InputDecoration(
                                        filled: true,
                                        labelText: 'デバイスの名を記入してください',
                                      ),
                                    ),
                                    SwitchListTile(
                                      contentPadding: EdgeInsets.only(
                                          left: 10.0, right: 10.0),
                                      title: Text("暗号化通信"),
                                      activeColor: Colors.blue,
                                      value: check,
                                      onChanged: (bool val) {
                                        setState(() {
                                          check = val;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                new FlatButton(
                                  child: new Text('确定'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                new FlatButton(
                                  child: new Text('取消'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                RaisedButton(
                  child: Text("削除"),
                  onPressed: () {
                    return showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: Text(
                                "本当にデバイスを削除しますか？",
                                style: TextStyle(fontSize: 20.0),
                              ),
                              content: SingleChildScrollView(
                                child: Text("注意：削除操作は戻れません。"),
                              ),
                              actions: <Widget>[
                                new FlatButton(
                                  child: new Text('确定'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                new FlatButton(
                                  child: new Text('取消'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                )
              ],
            ),
          ),
          Container(
            color: Colors.white,
            height: 550,
            child: ListView.builder(
              itemCount: list == null ? 0 : list.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4.0,
                  child: ListTile(
                    contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
                    title: CheckboxListTile(
                        contentPadding:
                            EdgeInsets.only(left: 10.0, right: 10.0),
                        title: Text("${index + 1}"),
                        activeColor: Colors.blue,
                        value: _checkValues[index],
                        onChanged: (bool val) {
                          setState(() {
                            _checkValues[index] = val;
                          });
                        }),
                    subtitle: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "デバイスID:",
                                style: TextStyle(fontSize: 12.0),
                              ),
                              Text(
                                list[index]["imei"],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "デバイス名:",
                                style: TextStyle(fontSize: 12.0),
                              ),
                              GestureDetector(
                                child: Text(
                                  list[index]["devicename"],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                onTap: () {
                                  return showDialog<Null>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: Text(
                                              list[index]["devicename"],
                                              style: TextStyle(fontSize: 20.0),
                                            ),
                                            content: SingleChildScrollView(
                                              child: ListBody(
                                                children: <Widget>[
                                                  GestureDetector(
                                                    child: RichText(
                                                      text: TextSpan(
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .body1,
                                                        children: [
                                                          WidgetSpan(
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      2.0),
                                                              child: Icon(Icons
                                                                  .volume_mute),
                                                            ),
                                                          ),
                                                          TextSpan(
                                                              text: "ブザー音",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      18.0)),
                                                        ],
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      return showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            false,
                                                        builder: (context) {
                                                          return StatefulBuilder(
                                                            builder: (context,
                                                                setState) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                  "操作を続行しますか",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20.0),
                                                                ),
                                                                content:
                                                                    SingleChildScrollView(
                                                                  child:
                                                                      ListBody(
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        "ブザーを鳴らしますか？",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                20.0),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                actions: <
                                                                    Widget>[
                                                                  new FlatButton(
                                                                    child:
                                                                        new Text(
                                                                            '确定'),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                  new FlatButton(
                                                                    child:
                                                                        new Text(
                                                                            '取消'),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                  GestureDetector(
                                                    child: RichText(
                                                      text: TextSpan(
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .body1,
                                                        children: [
                                                          WidgetSpan(
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      2.0),
                                                              child: Icon(Icons
                                                                  .power_settings_new),
                                                            ),
                                                          ),
                                                          TextSpan(
                                                              text: "デバイス制御",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      18.0)),
                                                        ],
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      return showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            false,
                                                        builder: (context) {
                                                          return StatefulBuilder(
                                                            builder: (context,
                                                                setState) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                  "デバイス制御",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20.0),
                                                                ),
                                                                content:
                                                                    SingleChildScrollView(
                                                                  child:
                                                                      ListBody(
                                                                    children: <
                                                                        Widget>[
                                                                      ButtonBar(
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: <Widget>[
                                                                              RaisedButton(
                                                                                child: Text("シャットダウン"),
                                                                                onPressed: () {},
                                                                              ),
                                                                              RaisedButton(
                                                                                child: Text("再起動"),
                                                                                onPressed: () {},
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                actions: <
                                                                    Widget>[
                                                                  new FlatButton(
                                                                    child:
                                                                        new Text(
                                                                            '确定'),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                  new FlatButton(
                                                                    child:
                                                                        new Text(
                                                                            '取消'),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                  GestureDetector(
                                                    child: RichText(
                                                      text: TextSpan(
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .body1,
                                                        children: [
                                                          WidgetSpan(
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      2.0),
                                                              child: Icon(
                                                                  Icons.create),
                                                            ),
                                                          ),
                                                          TextSpan(
                                                              text: "フェンス設定",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      18.0)),
                                                        ],
                                                      ),
                                                    ),
                                                    onTap: () {},
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              new FlatButton(
                                                child: new Text('确定'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              new FlatButton(
                                                child: new Text('取消'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "ICCID:",
                                  style: TextStyle(fontSize: 12.0),
                                ),
                                Text(
                                  list[index]["iccid"],
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              ]),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "バージョン",
                                style: TextStyle(fontSize: 12.0),
                              ),
                              if (list[index]["firmwareVersion"] != null)
                                GestureDetector(
                                  child: Text(
                                    list[index]["firmwareVersion"],
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  onTap: () {
                                    return getUpdata(
                                      index = index,
                                      imei = list[index]["imei"],
                                    );
                                  },
                                ),
                              if (list[index]["firmwareVersion"] == null)
                                Text(
                                  "データなし",
                                  style: TextStyle(
                                    fontSize: 12.0,
                                  ),
                                )
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "ネットワーク種類:",
                                style: TextStyle(fontSize: 12.0),
                              ),
                              if (list[index]["metadata"] != null &&
                                  list[index]["metadata"]["network"]["type"] ==
                                      3)
                                Text(
                                  "eMTC",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              if (list[index]["metadata"] == null)
                                Text(
                                  "データなし",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12.0),
                                ),
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "追跡モード:",
                                style: TextStyle(fontSize: 12.0),
                              ),
                              if (list[index]["metadata"] == null ||
                                  list[index]["metadata"]["period"] == null)
                                Text(
                                  "motion(Person)",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              if ((list[index]["metadata"] != null &&
                                      list[index]["metadata"]["period"] !=
                                          null) &&
                                  list[index]["metadata"]["period"]
                                          ["controlmode"] ==
                                      1)
                                Text(
                                  "find mode",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              if ((list[index]["metadata"] != null &&
                                      list[index]["metadata"]["period"] !=
                                          null) &&
                                  list[index]["metadata"]["period"]
                                          ["motionmode"] ==
                                      3)
                                Text(
                                  "motion(custom)",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "位置取得手段:",
                                style: TextStyle(fontSize: 12.0),
                              ),
                              if (list[index]["metadata"] == null ||
                                  (list[index]["metadata"]["gps"] == null ||
                                      (list[index]["metadata"]["gps"]
                                                  ["wifiEnable"] ==
                                              1 &&
                                          list[index]["metadata"]["gps"]
                                                  ["cellEnable"] ==
                                              1)))
                                GestureDetector(
                                  child: Text(
                                    "GPS,LBS,WLAN",
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  onTap: () {
                                    return showDialog<Null>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              return AlertDialog(
                                                title: Text(
                                                  "位置取得手段変更",
                                                  style:
                                                      TextStyle(fontSize: 20.0),
                                                ),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: <Widget>[
                                                      SwitchListTile(
                                                        secondary: const Icon(
                                                            Icons.network_wifi),
                                                        title: Text("WLAN"),
                                                        value:
                                                            _switchValue1list[
                                                                index],
                                                        onChanged:
                                                            (bool value) {
                                                          setState(() {
                                                            _switchValue1list[
                                                                index] = value;
                                                          });
                                                        },
                                                      ),
                                                      Divider(),
                                                      SwitchListTile(
                                                        secondary: const Icon(
                                                            Icons.network_cell),
                                                        title: Text("LBS"),
                                                        value:
                                                            _switchValue2list[
                                                                index],
                                                        onChanged:
                                                            (bool value) {
                                                          setState(() {
                                                            _switchValue2list[
                                                                index] = value;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  new FlatButton(
                                                    child: new Text('确定'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  new FlatButton(
                                                    child: new Text('取消'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        });
                                  },
                                ),
                              if (list[index]["metadata"] != null &&
                                  (list[index]["metadata"]["gps"] != null &&
                                      (list[index]["metadata"]["gps"]
                                                  ["wifiEnable"] ==
                                              1 &&
                                          list[index]["metadata"]["gps"]
                                                  ["cellEnable"] ==
                                              0)))
                                GestureDetector(
                                  child: Text(
                                    "GPS,WLAN",
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  onTap: () {
                                    return showDialog<Null>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              return AlertDialog(
                                                title: Text(
                                                  "位置取得手段変更",
                                                  style:
                                                      TextStyle(fontSize: 20.0),
                                                ),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: <Widget>[
                                                      SwitchListTile(
                                                        secondary: const Icon(
                                                            Icons.network_wifi),
                                                        title: Text("WLAN"),
                                                        value:
                                                            _switchValue1list[
                                                                index],
                                                        onChanged:
                                                            (bool value) {
                                                          setState(() {
                                                            _switchValue1list[
                                                                index] = value;
                                                          });
                                                        },
                                                      ),
                                                      Divider(),
                                                      SwitchListTile(
                                                        secondary: const Icon(
                                                            Icons.network_cell),
                                                        title: Text("LBS"),
                                                        value:
                                                            _switchValue2list[
                                                                index],
                                                        onChanged:
                                                            (bool value) {
                                                          setState(() {
                                                            _switchValue2list[
                                                                index] = value;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  new FlatButton(
                                                    child: new Text('确定'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  new FlatButton(
                                                    child: new Text('取消'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        });
                                  },
                                ),
                              if (list[index]["metadata"] != null &&
                                  (list[index]["metadata"]["gps"] != null &&
                                      (list[index]["metadata"]["gps"]
                                                  ["wifiEnable"] ==
                                              0 &&
                                          list[index]["metadata"]["gps"]
                                                  ["cellEnable"] ==
                                              1)))
                                GestureDetector(
                                  child: Text(
                                    "GPS,LBS",
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  onTap: () {
                                    return showDialog<Null>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              return AlertDialog(
                                                title: Text(
                                                  "位置取得手段変更",
                                                  style:
                                                      TextStyle(fontSize: 20.0),
                                                ),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: <Widget>[
                                                      SwitchListTile(
                                                        secondary: const Icon(
                                                            Icons.network_wifi),
                                                        title: Text("WLAN"),
                                                        value:
                                                            _switchValue1list[
                                                                index] = false,
                                                        onChanged:
                                                            (bool value) {
                                                          setState(() {
                                                            _switchValue1list[
                                                                index] = value;
                                                          });
                                                        },
                                                      ),
                                                      Divider(),
                                                      SwitchListTile(
                                                        secondary: const Icon(
                                                            Icons.network_cell),
                                                        title: Text("LBS"),
                                                        value:
                                                            _switchValue2list[
                                                                index],
                                                        onChanged:
                                                            (bool value) {
                                                          setState(() {
                                                            _switchValue2list[
                                                                index] = value;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  new FlatButton(
                                                    child: new Text('确定'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  new FlatButton(
                                                    child: new Text('取消'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        });
                                  },
                                ),
                              if (list[index]["metadata"] != null &&
                                  (list[index]["metadata"]["gps"] != null &&
                                      (list[index]["metadata"]["gps"]
                                                  ["wifiEnable"] ==
                                              0 &&
                                          list[index]["metadata"]["gps"]
                                                  ["cellEnable"] ==
                                              0)))
                                GestureDetector(
                                  child: Text(
                                    "GPS",
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  onTap: () {
                                    return showDialog<Null>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              return AlertDialog(
                                                title: Text(
                                                  "位置取得手段変更",
                                                  style:
                                                      TextStyle(fontSize: 20.0),
                                                ),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: <Widget>[
                                                      SwitchListTile(
                                                        secondary: const Icon(
                                                            Icons.network_wifi),
                                                        title: Text("WLAN"),
                                                        value:
                                                            _switchValue1list[
                                                                index] = false,
                                                        onChanged:
                                                            (bool value) {
                                                          setState(() {
                                                            _switchValue1list[
                                                                index] = value;
                                                          });
                                                        },
                                                      ),
                                                      Divider(),
                                                      SwitchListTile(
                                                        secondary: const Icon(
                                                            Icons.network_cell),
                                                        title: Text("LBS"),
                                                        value:
                                                            _switchValue2list[
                                                                index] = false,
                                                        onChanged:
                                                            (bool value) {
                                                          setState(() {
                                                            _switchValue2list[
                                                                index] = value;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  new FlatButton(
                                                    child: new Text('确定'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  new FlatButton(
                                                    child: new Text('取消'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
