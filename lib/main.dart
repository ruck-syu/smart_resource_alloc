import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_resource_alloc/router/app_router.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';
import 'package:smart_resource_alloc/services/offline_storage_service.dart';
import 'package:smart_resource_alloc/services/auth_service.dart';
import 'package:smart_resource_alloc/services/api_service.dart';
import 'package:smart_resource_alloc/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try initializing Firebase, but catch errors if not configured
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed (likely missing configuration): $e');
  }

  await OfflineStorageService.initialize();

  // Initialize services
  final authService = AuthService();
  final apiService = ApiService(authService);
  final fcmService = FcmService();

  // Initialize FCM (non-blocking)
  fcmService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        Provider<ApiService>.value(value: apiService),
        Provider<FcmService>.value(value: fcmService),
        ChangeNotifierProvider(
          create: (_) => AppState(apiService, authService),
        ),
      ],
      child: const SmartResourceApp(),
    ),
  );
}

class SmartResourceApp extends StatelessWidget {
  const SmartResourceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smart Resource Allocation',
      theme: AppTheme.darkTheme, // Enforcing premium dark theme for now
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
