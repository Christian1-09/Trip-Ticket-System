import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/admin/presentation/screens/admin_shell.dart';
import 'package:jtrips_app/features/auth/presentation/LoginPage.dart';
import 'package:jtrips_app/features/auth/presentation/RegisterScreen.dart';
import 'package:jtrips_app/features/welcome/welcome.dart';
import 'features/auth/presentation/RegisterPage.dart';
import 'features/driver/presentation/screens/driver_bottomMenu_Section.dart';
import 'features/instructor/presentation/screens/instructor_botton_bar.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Fixed: was RegisterScreen() (raw UI, no backend wiring) —
      // now RegisterPage() (the wrapper that actually calls your API).
      // home: const RegisterPage(),
      home: const RegisterPage(),
    );
  }
}

class DevMenu extends StatelessWidget {
  const DevMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DEV MENU")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BottonNavBar()),
            ),
            child: const Text("Faculty/Staff/SSG interface"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BottomMenuSection()),
            ),
            child: const Text("driver interface"),
          ),
          ElevatedButton(
            // Fixed: was RegisterScreen() — now RegisterPage()
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterPage()),
            ),
            child: const Text("Register"),
          ),
          ElevatedButton(
            // Fixed: was LoginScreen() — now LoginPage()
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
            child: const Text("login"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminShell()),
            ),
            child: const Text("Admin interface (web)"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Welcome()),
            ),
            child: const Text("Welcome"),
          ),
        ],
      ),
    );
  }
}