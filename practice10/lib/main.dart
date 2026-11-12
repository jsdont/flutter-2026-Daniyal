import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'countdown_screen.dart';
import 'students_future_screen.dart';
import 'students_screen.dart';

void main() {
  runApp(StudentsApp(api: FakeApi()));
}

class StudentsApp extends StatelessWidget {
  const StudentsApp({super.key, required this.api});

  final FakeApi api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Students',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const HomeScreen(),
      routes: {
        '/by-hand': (_) => StudentsScreen(api: api),
        '/future': (_) => StudentsFutureScreen(api: api),
        '/countdown': (_) => const CountdownScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice 10')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/by-hand'),
              child: const Text('By hand'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/future'),
              child: const Text('FutureBuilder'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/countdown'),
              child: const Text('Countdown'),
            ),
          ],
        ),
      ),
    );
  }
}
