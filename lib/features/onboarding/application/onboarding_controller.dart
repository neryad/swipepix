import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';

final onboardingProvider = NotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);

class OnboardingController extends Notifier<bool> {
  LocalStore get _store => ref.read(localStoreProvider);

  @override
  bool build() => _store.getBool(LocalStoreKeys.onboardingComplete) ?? false;

  void complete() {
    state = true;
    unawaited(
      _store
          .setBool(LocalStoreKeys.onboardingComplete, true)
          .catchError((_) {}),
    );
  }
}
