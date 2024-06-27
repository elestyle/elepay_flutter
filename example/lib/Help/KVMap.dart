import 'package:shared_preferences/shared_preferences.dart';

const String KV_KEY_pubKey = "pubKey";
const String KV_KEY_secKey = "secKey";

const String KV_KEY_cardNumber = "cardNumber";
const String KV_KEY_cardExpYear = "cardExpYear";
const String KV_KEY_cardExpMonth = "cardExpMonth";
const String KV_KEY_cardCVC = "cardCVC";

const String KV_KEY_trading = "trading";
const String KV_KEY_payment = "payment";
const String KV_KEY_finance = "finance";

const String KV_KEY_infosName = "infosName";
const String KV_KEY_infosEmail = "infosEmail";
const String KV_KEY_infosPhone = "infosPhone";
const String KV_KEY_infosCustomerId = "infosCustomerId";
const String KV_KEY_infosSourceId = "infosSourceId";

class KVMap {
  KVMap._();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static void set(String key, String value) {
    _prefs.setString(key, value);
  }

  static String? get(String key) {
    return _prefs.getString(key);
  }

  static void setInteger(String key, int value) {
    _prefs.setInt(key, value);
  }

  static int getInteger(String key) {
    return _prefs.getInt(key) ?? 0; // Return 0 if null
  }

  static void setBool(String key, bool value) {
    _prefs.setBool(key, value);
  }

  static bool getBool(String key) {
    return _prefs.getBool(key) ?? false; // Return false if null
  }

  static void remove(String key) {
    _prefs.remove(key);
  }
}
