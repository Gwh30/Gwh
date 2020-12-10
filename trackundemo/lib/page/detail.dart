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
  }

  @override
  void initState() {
    super.initState();
    _detail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: list == null ? 0 : list.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3.0,
            child: CheckboxListTile(
                contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
                title: Text("${index + 1}"),
                value: false,
                onChanged: (value) {
                  setState(() {
                    _checkValue = value;
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing),
          );
        },
      ),
    );
  }
}
