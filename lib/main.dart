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
      options: const FirebaseOptions(
        apiKey: "AIzaSyDIaFlrs_y3jdInTLEPQFEHOUugaClX7OE",
        appId: "1:519357833317:android:cf7cab9499fd133b53268c",
        messagingSenderId: "519357833317",
        projectId: "newsapp-4ade3",
        storageBucket: "newsapp-4ade3.firebasestorage.app",
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
        title: 'Portal News',
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
