import 'package:shared_preferences/shared_preferences.dart';

class StorageUtil {
  static SharedPreferences prefs;
  String token;

  static Future<void> init() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
  }

  setString(key, value) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  getString(key) async {
    prefs = await SharedPreferences.getInstance();
    token = await prefs.getString(key);
  }
}
