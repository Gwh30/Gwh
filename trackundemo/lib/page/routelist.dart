import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:trackundemo/src/locations.dart' as locations;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackundemo/util/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RouteList extends StatefulWidget {
  String datas;
  RouteList({Key key, this.datas}) : super(key: key);
  @override
  _RouteListState createState() => _RouteListState();
}

class _RouteListState extends State<RouteList> {
  List list = [];
  Future _getList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = {
      'pageNumber': '1',
      'pageSize': '100',
      'imei': '${widget.datas}',
      'startData': '20201130',
      'endData': '20201130',
      'startTime': '000000',
      'endTime': '235959',
    };
    String token = prefs.getString('token');
    RequestOptions requestOptions =
        new RequestOptions(baseUrl: 'https://demo.trackun.jp', extra: {
      'context': context,
    }, headers: {
      'Authorization': 'Bearer ${token}',
      'Content-Type': 'application/json;charset=utf-8',
    });
    CancelToken cancelToken;
    // 862211044198299
    var response = await HttpUtil().get(
      '/v1.0/deviceData/byUser?pageNumber=1&pageSize=100&imei=${widget.datas}&startDate=20201127&endDate=20201127&startTime=000000&endTime=235959',
      data: data,
      options: requestOptions,
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200) {
      setState(() {
        list = json.decode(response.data)['list'];
        for (int i = 0; i < list.length; i++) {
          prefs.setString('uname' + i.toString(), list[i]['time']);
          prefs.setDouble('ulat' + i.toString(), list[i]['lat']);
          prefs.setDouble('ulng' + i.toString(), list[i]['lng']);
        }

        for (int i = 0; i < list.length; i++) {
          final umarker = Marker(
            markerId: MarkerId(prefs.getString('uname' + i.toString())),
            position: LatLng(prefs.getDouble('ulat' + i.toString()),
                prefs.getDouble('ulng' + i.toString())),
            infoWindow: InfoWindow(
              title: prefs.getString('uname' + i.toString()),
            ),
          );
          _markers[prefs.getString('uname' + i.toString())] = umarker;
        }

        for (int i = 0; i < list.length; i++) {
          prefs.remove('uname' + i.toString());
          prefs.remove('ulat' + i.toString());
          prefs.remove('ulng' + i.toString());
        }
      });
    } else {
      print('Error${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _getList();
  }

  Iterable markers = [];
  GoogleMapController mapController;
  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    final googleOffices = await locations.getGoogleOffices();
    setState(() {
      _markers.clear();
      for (final office in googleOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
          ),
        );
        _markers[office.name] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 50,
          width: 450,
          child: RaisedButton(
            child: Text('日付の選択'),
            onPressed: () async {
              var date = showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2010),
                  lastDate: DateTime(2030),
                  initialDatePickerMode: DatePickerMode.year,
                  selectableDayPredicate: (date) {
                    return date.difference(DateTime.now()).inMilliseconds < 0;
                  });
            },
          ),
        ),
        Container(
          height: 50,
          width: 450,
          child: RaisedButton(
            child: Text('時間の選択'),
            onPressed: () async {
              var result = showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  initialEntryMode: TimePickerEntryMode.input,
                  builder: (BuildContext context, Widget child) {
                    return MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(alwaysUse24HourFormat: true),
                      child: child,
                    );
                  });
            },
          ),
        ),
        Container(
          height: 290,
          width: 450,
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: const LatLng(35.504379, 139.678757),
              zoom: 17.0,
            ),
            myLocationEnabled: true,
            markers: _markers.values.toSet(),
          ),
        ),
        Container(
          height: 280,
          width: 450,
          child: ListView.builder(
            itemCount: list == null ? 0 : list.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
                  leading: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Text("$index"),
                      ),
                    ],
                  ),
                  title: Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      list[index]["date"].toString() +
                          "           " +
                          list[index]["time"].toString(),
                      maxLines: 2,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: Colors.deepPurple, fontSize: 16.0),
                    ),
                  ),
                  subtitle: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "緯度:" + "           " + list[index]["lat"].toString(),
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "経度:" + "           " + list[index]["lng"].toString(),
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "精度:" +
                              "           " +
                              list[index]["accuracy"].toString(),
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "電波レベル:" +
                              "           " +
                              list[index]["netSignal"].toString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "バッテリー:" +
                              "           " +
                              list[index]["batterypercent"].toString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                      // Text(
                      //   list[index]["batteryInfo"]["batteryPercentage"].toString() +
                      //       "%",
                      //   style: TextStyle(fontSize: 12.0),
                      // ),
                    ],
                  ),
                  // trailing: Text(list[index]["watchStatus"]["status"].toString()),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
