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
  var _switchValue1 = false;
  var _switchValue2 = false;
  List<bool> _checkValues = [];
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

  void showSwitch() {
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text(
              "位置取得手段変更",
              style: TextStyle(fontSize: 20.0),
            ),
            content: new SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SwitchListTile(
                    secondary: const Icon(Icons.network_wifi),
                    title: Text("WLAN"),
                    value: _switchValue1,
                    onChanged: (bool value) {
                      setState(() {
                        _switchValue1 = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.network_cell),
                    title: Text("LBS"),
                    value: _switchValue2,
                    onChanged: (bool value) {
                      setState(() {
                        _switchValue2 = value;
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
        });
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
      body: ListView.builder(
        itemCount: list == null ? 0 : list.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4.0,
            child: ListTile(
              contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
              title: CheckboxListTile(
                  contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
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
                          onTap: () {},
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
                      children: <Widget>[
                        Text(
                          "バージョン",
                          style: TextStyle(fontSize: 12.0),
                        ),
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
                            return showSwitch();
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
    );
  }
}
