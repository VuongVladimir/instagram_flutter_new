import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter_new/providers/user_provider.dart';
import 'package:instagram_flutter_new/responsive/mobile_screen_layout.dart';
import 'package:instagram_flutter_new/responsive/responsive_screen_layout.dart';
import 'package:instagram_flutter_new/responsive/web_screen_layout.dart';
import 'package:instagram_flutter_new/screens/login_screen.dart';
import 'package:instagram_flutter_new/screens/signup_screen.dart';
import 'package:instagram_flutter_new/utils/colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: "AIzaSyD0l7q12J0wRDkp2pkVj_SmI9-0dToadeA",
      appId: "1:640374514124:web:45bde434fc420781797d69",
      messagingSenderId: "640374514124",
      projectId: "instagram-new-d2222",
      storageBucket: "instagram-new-d2222.appspot.com",
    ));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram Demo',
        theme: ThemeData.dark().copyWith(
          //scaffoldBackgroundColor: mobileBackgroundColor,
          scaffoldBackgroundColor: newBackgroundColor,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return const ResponsiveLayout(
                  WebScreenLayout(),
                  MobileScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              );
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
