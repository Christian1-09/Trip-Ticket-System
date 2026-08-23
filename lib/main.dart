import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/admin/presentation/screens/admin_shell.dart';
import 'package:jtrips_app/features/auth/presentation/LoginScreen.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/driver_bottomMenu_Section.dart';
import 'package:jtrips_app/features/welcome/welcome.dart';
import 'features/auth/presentation/RegisterScreen.dart';
import 'features/instructor/presentation/screens/widgets/instructor_botton_bar.dart';


void main() {
  runApp(
      const ProviderScope(
        child:MyApp(),
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DevMenu(),
    );
  }
}


class DevMenu extends StatelessWidget {
  const DevMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("DEV MENU"),),
      body: Column(
        children: [
          ElevatedButton(onPressed: () =>
              Navigator.push(context,MaterialPageRoute(builder: (_) => BottonNavBar())),
              child: Text("Instructor interface")),

          ElevatedButton(onPressed: () =>
              Navigator.push(context,MaterialPageRoute(builder: (_) => BottomMenuSection())),
              child: Text("driver interface")),
          ElevatedButton(onPressed: () =>
              Navigator.push(context,MaterialPageRoute(builder: (_) => RegisterScreen())),
              child: Text("Register")),

          ElevatedButton(onPressed: () =>
              Navigator.push(context,MaterialPageRoute(builder: (_) => LoginScreen())),
              child: Text("login")),

          ElevatedButton(onPressed: () =>
              Navigator.push(context,MaterialPageRoute(builder: (_) => AdminShell())),
              child: Text("Admin interface (web)")),

          ElevatedButton(onPressed: () =>
              Navigator.push(context,MaterialPageRoute(builder: (_) => Welcome())),
              child: Text("Welcome")),

        ],
      ),
    );
  }
}
