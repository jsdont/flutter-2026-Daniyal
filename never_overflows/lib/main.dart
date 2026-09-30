import 'package:flutter/material.dart';

import 'contact_list.dart';

void main() => runApp(const MyApp());

const seedColor = Colors.deepPurple;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seedColor)),
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
    ),
    themeMode: ThemeMode.system,
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Contacts'),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    ),
    body: const SafeArea(child: ContactList()),
  );
}
