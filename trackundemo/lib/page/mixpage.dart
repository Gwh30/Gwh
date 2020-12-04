import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackundemo/src/locations.dart' as locations;
import 'dart:async';
import 'dart:convert';
import 'package:trackundemo/page/routelist.dart';
import 'package:trackundemo/util/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MixPage extends StatefulWidget {
  // MixPage({Key key, this.title}) : super(key: key);
  // final String title;
  @override
  _MixPageState createState() => _MixPageState();
}

class _MixPageState extends State<MixPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: _sliverBuilder,
        body: Center(
          child: ListView.builder(
            itemBuilder: _itemBuilder,
            itemCount: list == null ? 0 : list.length,
          ),
        ),
      ),
    );
  }

  Iterable markers = [];
  List list = [];
  GoogleMapController mapController;
  final Map<String, Marker> _markers = {};
  int n = 0;
  Future getData() async {
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
        // for (int i = 0; i < list.length; i++) {
        //   // prefs.setString('imei' + i.toString(), list[i]['imei']);
        //   prefs.setString('name' + i.toString(), list[i]['deviceName']);
        //   prefs.setDouble(
        //       'lat' + i.toString(), list[i]['deviceLocation']['lat']);
        //   prefs.setDouble(
        //       'lng' + i.toString(), list[i]['deviceLocation']['lng']);
        // }

        for (int i = 0; i < list.length; i++) {
          final umarker = Marker(
            markerId: MarkerId(prefs.getString('name') + i.toString()),
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

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        centerTitle: true, //标题居中
        expandedHeight: 300.0, //展开高度200
        floating: false, //不随着滑动隐藏标题
        pinned: true, //固定在顶部
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Text('ミックス'),
          background: Scaffold(
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
          ),
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
        leading: Row(
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
            list[index]["imei"],
            maxLines: 2,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.deepPurple, fontSize: 16.0),
          ),
        ),
        subtitle: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Text(
                list[index]["deviceName"],
                style: TextStyle(fontSize: 12.0),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return RouteList(
                datas: list[index]["imei"],
              );
            },
          ));
        },
      ),
    );
  }
}
