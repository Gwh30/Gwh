import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:trackundemo/util/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataList extends StatefulWidget {
  @override
  _DataListState createState() => _DataListState();
}

class _DataListState extends State<DataList> {
  List list = [];
  Future _getData() async {
    var data = {
      'pageNumber': '1',
      'pageSize': '100',
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
      '/v1.0/deviceStatus/list?pageNumber=1&pageSize=100',
      data: data,
      options: requestOptions,
      cancelToken: cancelToken,
    );
// Utf8Decoder decode = new Utf8Decoder();
    if (response.statusCode == 200) {
      setState(() {
        list = json.decode(response.data)['list'];
        print(list);
      });
    } else {
      print('Error${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: list == null ? 0 : list.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3.0,
            child: ListTile(
              contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
              leading: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Text("${index + 1}"),
                  ),
                ],
              ),
              title: Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "トラッカー名:" +
                      "                      " +
                      list[index]["deviceName"],
                  maxLines: 2,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.deepPurple, fontSize: 16.0),
                ),
              ),
              subtitle: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "ドラッカーIMEI:",
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "状態:",
                            style: TextStyle(fontSize: 12.0),
                          ),
                          if (list[index]["status"] == 0)
                            Text(
                              "offline",
                              style: TextStyle(fontSize: 12.0),
                            ),
                          if (list[index]["status"] == 2)
                            Text(
                              "power off",
                              style: TextStyle(fontSize: 12.0),
                            ),
                          if (list[index]["status"] == 1)
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: list[index]["batteryInfo"]
                                              ["batteryPercentage"]
                                          .toString() +
                                      "%",
                                  style: TextStyle(fontSize: 12.0),
                                ),
                                if (list[index]["batteryInfo"]
                                        ["batteryPercentage"] >=
                                    70)
                                  WidgetSpan(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                    child: Icon(IconData(0xe697,
                                        fontFamily: 'MyIcons')),
                                  )),
                                if (list[index]["batteryInfo"]
                                            ["batteryPercentage"] >
                                        50 &&
                                    list[index]["batteryInfo"]
                                            ["batteryPercentage"] <
                                        70)
                                  WidgetSpan(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                    child: Icon(IconData(0xe696,
                                        fontFamily: 'MyIcons')),
                                  )),
                                if (list[index]["batteryInfo"]
                                            ["batteryPercentage"] >=
                                        30 &&
                                    list[index]["batteryInfo"]
                                            ["batteryPercentage"] <=
                                        50)
                                  WidgetSpan(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                    child: Icon(IconData(0xe695,
                                        fontFamily: 'MyIcons')),
                                  )),
                                if (list[index]["batteryInfo"]
                                        ["batteryPercentage"] <
                                    30)
                                  WidgetSpan(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                    child: Icon(IconData(0xe694,
                                        fontFamily: 'MyIcons')),
                                  )),
                              ]),
                            ),
                        ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "最後通信時間:",
                          style: TextStyle(fontSize: 12.0),
                        ),
                        Text(
                          list[index]["lastUpdateTime"],
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "最後電池レベル:",
                          style: TextStyle(fontSize: 12.0),
                        ),
                        Text(
                          list[index]["batteryInfo"]["batteryPercentage"]
                                  .toString() +
                              "%",
                          style: TextStyle(fontSize: 12.0),
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
