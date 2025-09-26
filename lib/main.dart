import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'providers/task_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for Thai locale
  await initializeDateFormatting('th', null);
  
  // Initialize Hive
  await HiveService.initialize();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // สร้างธีมสำหรับโหมดแสง
  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1), // สีม่วงอินดิโก้สวยงาม
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }

  // สร้างธีมสำหรับโหมดมืด
  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1), // สีม่วงอินดิโก้สวยงาม
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'แอปจัดการงาน & นิสัย',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
