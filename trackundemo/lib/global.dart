import 'package:flutter/material.dart';
import 'package:trackundemo/storage.dart';

class Global {
  static var profile;

  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 工具初始
    await StorageUtil.init();
    // HttpUtil();
  }

  static saveProfile(response) {
    profile = response;
    return StorageUtil().setString('token', response);
  }
}
