import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init locale data untuk DateFormat('id_ID')
  await initializeDateFormatting('id_ID', null);

  // Suppress go_router StateError saat deep link budgetmate:// diterima —
  // error ini harmless karena app_links sudah handle token sebelum go_router
  FlutterError.onError = (FlutterErrorDetails details) {
    final isDeepLinkSchemeError = details.exception is StateError &&
        details.exception.toString().contains('Origin is only applicable');
    if (!isDeepLinkSchemeError) {
      FlutterError.presentError(details);
    }
  };

  // Firebase init (skip jika belum configure)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  runApp(
    const ProviderScope(
      child: BudgetMateApp(),
    ),
  );
}
