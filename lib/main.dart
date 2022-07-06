import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screen/auth/log_in_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'helper/share_preference_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: SharedPreferenceScreen(),
        ),
        ChangeNotifierProvider.value(
          value: UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ChatApp',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          backgroundColor: Colors.teal,
          accentColor: Colors.lightBlueAccent,
          accentColorBrightness: Brightness.light,
          buttonTheme: ButtonTheme.of(context).copyWith(
            buttonColor: Colors.teal,
            textTheme: ButtonTextTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            color: Colors.white,
            centerTitle: true,
          ),
        ),
        home:
            const LogInScreen(), /*StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            if (userSnapshot.hasData) {
              return const UsersScreen();
            } else {
              return const LogInScreen();
            }
          },
        ),*/
      ),
    );
  }
}
