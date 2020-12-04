import 'package:dio/dio.dart';
import 'package:trackundemo/util/http.dart';

class DoLogin {
  static Future login({
    var data,
    Options options,
    CancelToken cancelToken,
  }) async {
    var response = await HttpUtil().post(
      '/auth/realms/trackun/protocol/openid-connect/token',
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
    return response;
  }
}
