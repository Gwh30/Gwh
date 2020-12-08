import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackundemo/src/locations.dart' as locations;
import 'package:trackundemo/util/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Iterable markers = [];
  List list = [];
  GoogleMapController mapController;
  final Map<String, Marker> _markers = {};

  Future _getData() async {
    var data = {
      'pageNumber': '1',
      'pageSize': '100',
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    RequestOptions requestOptions =
        new RequestOptions(baseUrl: 'https://demo.trackun.jp', headers: {
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
    if (response.statusCode == 200) {
      setState(() {
        list = json.decode(response.data)['list'];
        for (int i = 0; i < list.length; i++) {
          prefs.setString('name' + i.toString(), list[i]['deviceName']);
          prefs.setDouble(
              'lat' + i.toString(), list[i]['deviceLocation']['lat']);
          prefs.setDouble(
              'lng' + i.toString(), list[i]['deviceLocation']['lng']);
        }

        for (int i = 0; i < list.length; i++) {
          final umarker = Marker(
            markerId: MarkerId(prefs.getString('name' + i.toString())),
            position: LatLng(prefs.getDouble('lat' + i.toString()),
                prefs.getDouble('lng' + i.toString())),
            infoWindow: InfoWindow(
              title: prefs.getString('name' + i.toString()),
            ),
          );
          _markers[prefs.getString('name' + i.toString())] = umarker;
        }
      });
    } else {
      print('Error${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
    // _onMapCreated(mapController);
  }

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
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: const LatLng(35.672318, 139.77829),
                zoom: 17.0,
              ),
              myLocationEnabled: true,
              markers: _markers.values.toSet(),
            ),
          ),
          // body: Container(
          //   child: GoogleMap(
          //     markers: Set.from(
          //       markers,
          //     ),
          //     initialCameraPosition: CameraPosition(
          //         target: const LatLng(35.6580339, 139.7016358), zoom: 15.0),
          //     onMapCreated: (GoogleMapController controller) {},
          //   ),
          // ),
        ),
      );
}
