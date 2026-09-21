import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';

final localeProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale?> {
  LocalStore get _store => ref.read(localStoreProvider);

  @override
  Locale? build() {
    final code = _store.getString(LocalStoreKeys.locale);
    return code == null ? null : Locale(code);
  }

  void select(Locale? value) {
    state = value;
    unawaited(
      (value == null
              ? _store.remove(LocalStoreKeys.locale)
              : _store.setString(LocalStoreKeys.locale, value.languageCode))
          .catchError((_) {}),
    );
  }
}

final themeProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);

class ThemeController extends Notifier<ThemeMode> {
  LocalStore get _store => ref.read(localStoreProvider);

  @override
  ThemeMode build() {
    final name = _store.getString(LocalStoreKeys.theme);
    return ThemeMode.values.where((mode) => mode.name == name).firstOrNull ??
        ThemeMode.system;
  }

  void select(ThemeMode value) {
    state = value;
    unawaited(
      _store.setString(LocalStoreKeys.theme, value.name).catchError((_) {}),
    );
  }
}
