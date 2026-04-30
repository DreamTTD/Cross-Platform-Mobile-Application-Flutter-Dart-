
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/providers/auth_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
