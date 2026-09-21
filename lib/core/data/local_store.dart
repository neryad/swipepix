import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocalStore {
  bool? getBool(String key);
  String? getString(String key);
  Future<void> setBool(String key, bool value);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

abstract final class LocalStoreKeys {
  static const onboardingComplete = 'swipepix.onboarding.complete';
  static const locale = 'swipepix.settings.locale';
  static const theme = 'swipepix.settings.theme';
  static const gallerySort = 'swipepix.gallery.sort';
  static const cleanupSession = 'swipepix.cleanup.session.v1';

  static const all = <String>{
    onboardingComplete,
    locale,
    theme,
    gallerySort,
    cleanupSession,
  };
}

class MemoryLocalStore implements LocalStore {
  final Map<String, Object> _values = {};

  @override
  bool? getBool(String key) => _values[key] as bool?;

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  Future<void> setBool(String key, bool value) async {
    _values[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }
}

class SharedPreferencesLocalStore implements LocalStore {
  const SharedPreferencesLocalStore(this._preferences);

  final SharedPreferencesWithCache _preferences;

  @override
  bool? getBool(String key) => _preferences.getBool(key);

  @override
  String? getString(String key) => _preferences.getString(key);

  @override
  Future<void> setBool(String key, bool value) =>
      _preferences.setBool(key, value);

  @override
  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);

  @override
  Future<void> remove(String key) => _preferences.remove(key);
}

Future<LocalStore> createProductionLocalStore() async {
  final preferences = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: LocalStoreKeys.all,
    ),
  );
  return SharedPreferencesLocalStore(preferences);
}

final localStoreProvider = Provider<LocalStore>((ref) => MemoryLocalStore());
