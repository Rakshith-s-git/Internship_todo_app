import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:task_manager_app/pages/login_page.dart';
import 'package:task_manager_app/pages/registration_page.dart';
import 'firebase_option.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Init Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 189, 180, 203),
        ),
        useMaterial3: true,
      ),

      // ✅ Builder provides correct Navigator context
      home: Builder(
        builder: (context) {
          return LoginPage(
            onRegisterPressed: () {
              debugPrint('Register pressed');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RegistrationPage(
                    onLoginPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
