import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';

final userNameProvider = StateProvider<String>((ref) {
  return StorageService.instance.getUserName();
});

final darkModeProvider = StateProvider<bool>((ref) {
  return StorageService.instance.isDarkMode;
});

final updateUserNameProvider = Provider<void Function(String)>((ref) {
  return (String name) async {
    await StorageService.instance.setUserName(name);
    ref.read(userNameProvider.notifier).state = name;
  };
});

final toggleDarkModeProvider = Provider<void Function(bool)>((ref) {
  return (bool value) async {
    await StorageService.instance.setDarkMode(value);
    ref.read(darkModeProvider.notifier).state = value;
  };
});
