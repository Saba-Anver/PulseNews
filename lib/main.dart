import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:portal_news/presentation/pages/login_page.dart';
import 'package:portal_news/presentation/main_pages/main_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:portal_news/service/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // 1. Essential: Initialize Flutter's binding
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  try {
    print("INITIALIZING FIREBASE...");

    // 2. Manual Initialization using your specific JSON data
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY']!,
        appId: dotenv.env['FIREBASE_APP_ID']!,
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
        projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      ),
    );

    print("FIREBASE INITIALIZED SUCCESSFULLY!");
  } catch (e) {
    print("FIREBASE INITIALIZATION ERROR: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pulse News',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        // 3. The StreamBuilder handles the "Auth Logic"
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // While Firebase is checking the connection...
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            // If the user is logged in, go to Main Page
            if (snapshot.hasData) {
              return MainPage();
            }
            // Otherwise, show the Login Page
            return const LoginPage();
          },
        ),
      ),
    );
  }
}
