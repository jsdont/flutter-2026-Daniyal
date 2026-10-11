import 'package:flutter/material.dart';

import 'models/study_session.dart';
import 'routes.dart';
import 'screens/session_detail_screen.dart';
import 'screens/session_form_screen.dart';
import 'screens/shell_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  ThemeData _theme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const ColorScheme.light().primary,
        brightness: brightness,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Meet',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: _themeMode,
      initialRoute: Routes.home,
      routes: {
        Routes.home: (context) =>
            ShellScreen(themeMode: _themeMode, onThemeChanged: _changeTheme),
      },
      onGenerateRoute: (settings) {
        final arguments = settings.arguments;
        if (settings.name == Routes.detail && arguments is DetailArguments) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (context) => SessionDetailScreen(
              session: arguments.session,
              profile: arguments.profile,
              onChanged: arguments.onChanged,
              onDeleted: arguments.onDeleted,
              onOpenProfile: arguments.onOpenProfile,
            ),
          );
        }
        if (settings.name == Routes.form && arguments is FormArguments) {
          return MaterialPageRoute<StudySession>(
            settings: settings,
            builder: (context) => SessionFormScreen(session: arguments.session),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Not found')),
          body: const Center(child: Text('This screen does not exist.')),
        ),
      ),
    );
  }
}
