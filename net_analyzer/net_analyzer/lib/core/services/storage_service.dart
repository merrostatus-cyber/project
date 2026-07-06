import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  static StorageService get instance {
    if (_instance == null) {
      throw StateError(
        'StorageService not initialized. Call getInstance() first.',
      );
    }
    return _instance!;
  }

  SharedPreferences get prefs => _prefs;

  String getUserName() => _prefs.getString(AppConstants.storageUserName) ?? '';

  Future<bool> setUserName(String name) =>
      _prefs.setString(AppConstants.storageUserName, name);

  bool get isDarkMode => _prefs.getBool(AppConstants.storageIsDarkMode) ?? true;

  Future<bool> setDarkMode(bool value) =>
      _prefs.setBool(AppConstants.storageIsDarkMode, value);

  bool get hasSeenOnboarding =>
      _prefs.getBool(AppConstants.storageHasSeenOnboarding) ?? false;

  Future<bool> setHasSeenOnboarding(bool value) =>
      _prefs.setBool(AppConstants.storageHasSeenOnboarding, value);
}
