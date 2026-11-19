import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UsersModel(UserRepository.network())..load(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const UsersScreen(),
    );
  }
}
