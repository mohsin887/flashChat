import 'package:chat_app/helper/share_prefs.dart';
import 'package:chat_app/helper/user_model.dart';
import 'package:chat_app/provider/auth.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/provider/users.dart';
import 'package:chat_app/screen/auth/log_in_screen.dart';
import 'package:chat_app/screen/splash_screen.dart';
import 'package:chat_app/screen/user_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          value: Users(),
        ),
        ChangeNotifierProvider.value(
          value: UserModel(),
        ),
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: Preference(),
        ),
        ChangeNotifierProvider.value(
          value: UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ChatApp',
        theme: ThemeData(
          backgroundColor: Colors.teal,
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
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal)
              .copyWith(secondary: Colors.lightBlueAccent),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            if (userSnapshot.hasData) {
              return const UserListScreen();
            } else {
              return const LogInScreen();
            }
          },
        ),
      ),
    );
  }
}
