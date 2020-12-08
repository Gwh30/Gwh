import 'dart:convert';
import 'package:trackundemo/src/locations.dart' as locations;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackundemo/util/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RouteList extends StatefulWidget {
  String datas;
  String name;
  RouteList({Key key, this.datas, this.name}) : super(key: key);
  @override
  _RouteListState createState() => _RouteListState();
}

class _RouteListState extends State<RouteList> {
  var _time;
  var _date;
  List list = [];
  Future _showDataPicker() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Locale myLocale = Localizations.localeOf(context);
    var picker = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
      locale: myLocale,
    );
    var tpicker = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.input,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child,
          );
        });
    setState(() {
      _date = picker.toString();
      String syear = picker.start.year.toString();
      String smonth = picker.start.month.toString();
      String sday = picker.start.day.toString();
      if (smonth.length < 2) {
        smonth = '0' + smonth;
      } else {
        smonth = smonth;
      }
      if (sday.length < 2) {
        sday = '0' + sday;
      } else {
        sday = sday;
      }
      String startdate = syear + smonth + sday;
      prefs.setString('startdate', startdate);
      String eyear = picker.end.year.toString();
      String emonth = picker.end.month.toString();
      String eday = picker.end.day.toString();
      if (emonth.length < 2) {
        emonth = '0' + emonth;
      } else {
        emonth = emonth;
      }
      if (eday.length < 2) {
        eday = '0' + eday;
      } else {
        eday = eday;
      }
      String enddate = eyear + emonth + eday;
      prefs.setString('enddate', enddate);

      _time = tpicker.toString();
      String hour = tpicker.hour.toString();
      String minute = tpicker.minute.toString();
      if (hour.length < 2) {
        hour = '0' + hour;
      } else {
        hour = hour;
      }
      if (minute.length < 2) {
        minute = '0' + minute;
      } else {
        minute = minute;
      }
      String time = hour + minute + '00';
      prefs.setString('time', time);
    });
    String startdate = prefs.getString('startdate');
    String enddate = prefs.getString('enddate');
    String time = prefs.getString('time');

    var data;
    var response;
    data = {
      'pageNumber': '1',
      'pageSize': '100',
      'imei': '${widget.datas}',
      'startDate': '$startdate',
      'endDate': '$enddate',
      'startTime': '000000',
      'endTime': '$time',
    };
    String token = prefs.getString('token');
    RequestOptions requestOptions =
        new RequestOptions(baseUrl: 'https://demo.trackun.jp', extra: {
      'context': context,
    }, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json;charset=utf-8',
    });
    CancelToken cancelToken;
    response = await HttpUtil().get(
      '/v1.0/deviceData/byUser?pageNumber=1&pageSize=100&imei=${widget.datas}&startDate=$startdate&endDate=$enddate&startTime=000000&endTime=$time',
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
      });
    } else {
      print('Error${response.statusCode}');
    }

    // for (int i = 0; i < list.length; i++) {
    //   prefs.remove('uname' + i.toString());
    //   prefs.remove('ulat' + i.toString());
    //   prefs.remove('ulng' + i.toString());
    // }
  }

  @override
  void initState() {
    super.initState();
    // _getList();
    _showDataPicker();
    _onMapCreated(mapController);
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
          child: Card(
            child: ListTile(),
          ),
        ),
        Container(
          height: 50,
          width: 450,
          child: RaisedButton(
            child: Text('日付の選択'),
            onPressed: () => _showDataPicker(),
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
                        child: Text("${index + 1}"),
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
