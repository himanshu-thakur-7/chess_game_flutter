import './screens/puzzles_screen.dart';
import 'package:flutter/services.dart';

import './screens/learn_chess_screen.dart';
import './widgets/timer_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import './screens/home_screen.dart';
import 'screens/splash_screen.dart';
import "screens/auth_screen.dart";

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color.fromRGBO(34, 0, 53, 1.0),
          accentColor: const Color.fromRGBO(251, 209, 76, 1.0),
          buttonTheme: const ButtonThemeData(
              buttonColor: Color.fromRGBO(155, 26, 228, 1.0)),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, AsyncSnapshot<User?> userSnapshot) {
            if (userSnapshot.hasData) {
              print(userSnapshot.data);

              var userOnDeviceID = userSnapshot.data!.uid;

              return SplashScreen(userOnDeviceID: userOnDeviceID);
            }
            return const AuthScreen();
          },
        )
        // home: PuzzleScreen(),
        );
  }
}
