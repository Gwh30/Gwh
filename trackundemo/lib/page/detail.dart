import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:trackundemo/util/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackundemo/util/http.dart';

class Detail extends StatefulWidget {
  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  var _checkValue = false;
  List<bool> _checkValues = [];
  List list = [];
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
        print(list);
      });
    } else {
      print('Error${response.statusCode}');
    }
    for (int i = 0; i < list.length; i++) {
      _checkValues.add(false);
    }
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
                        Text(
                          list[index]["devicename"],
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
                        Text(
                          list[index]["firmwareVersion"],
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
                          "位置取得手段:",
                          style: TextStyle(fontSize: 12.0),
                        ),
                        Text(
                          "GPS,LBS,WLAN",
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 10.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       Text(
                  //         "最後電池レベル:",
                  //         style: TextStyle(fontSize: 12.0),
                  //       ),
                  //       Text(
                  //         list[index]["batteryInfo"]["batteryPercentage"]
                  //                 .toString() +
                  //             "%",
                  //         style: TextStyle(fontSize: 12.0),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
            // CheckboxListTile(
            //     contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
            //     title: Text("${index + 1}"),
            //     activeColor: Colors.blue, //激活时的颜色
            //     value: _checkValues[index],
            //     onChanged: (bool val) {
            //       setState(() {
            //         _checkValues[index] = val;
            //       });
            //     }),
          );
        },
      ),
    );
  }
}
