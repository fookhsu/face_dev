import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/ai_studio_screen.dart';
import 'screens/my_profile_screen.dart';
import 'styles/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/payment_provider.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化API服务
  await ApiService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DIY Swap',
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const AIStudioScreen(),
        '/profile': (context) => const MyProfileScreen(),
      },
    );
  }
}
