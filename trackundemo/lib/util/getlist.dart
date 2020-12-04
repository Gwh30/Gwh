import 'package:trackundemo/util/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class GetList {
  Future getlist() async {
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
    return response;
  }
}
