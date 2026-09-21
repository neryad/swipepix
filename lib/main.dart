import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/data/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalStore store;
  try {
    store = await createProductionLocalStore();
  } catch (_) {
    store = MemoryLocalStore();
  }
  runApp(
    ProviderScope(
      overrides: [localStoreProvider.overrideWithValue(store)],
      child: const SwipePixApp(),
    ),
  );
}
