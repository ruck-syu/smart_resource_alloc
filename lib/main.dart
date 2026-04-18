import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_resource_alloc/router/app_router.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';
import 'package:smart_resource_alloc/services/offline_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OfflineStorageService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
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
