import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'state/auth_state.dart';
import 'state/student_state.dart';
import 'state/club_state.dart';
import 'state/notification_state.dart';
import 'features/welcome/screens/role_selection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CQubeApp());
}

class CQubeApp extends StatelessWidget {
  const CQubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => StudentState()),
        ChangeNotifierProvider(create: (_) => ClubState()),
        ChangeNotifierProvider(create: (_) => NotificationState()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const RoleSelectionScreen(),
          );
        },
      ),
    );
  }
}
