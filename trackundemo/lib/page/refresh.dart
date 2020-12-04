import 'package:dio/dio.dart';
import 'package:trackundemo/util/http.dart';

class Refresh {
  static Future refresh({
    var data,
    Options options,
    CancelToken cancelToken,
  }) async {
    var response = await HttpUtil().post(
      'v1.0/user/refresh',
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
    return response;
  }
}
