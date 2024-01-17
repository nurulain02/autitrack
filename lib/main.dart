import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:workshop_2/screen/HomePage.dart';
import 'package:workshop_2/screen/graph.dart';
import 'package:workshop_2/screen/mainFeedPageEdu.dart';
import 'package:workshop_2/screen/mainFeedPageParent.dart';
import 'package:workshop_2/screen/mainScreen.dart';
import 'package:workshop_2/screen/mainScreenEdu.dart';
import 'package:workshop_2/screen/moodPage.dart';
import 'firebase_options.dart';

import 'messages/homeScreenEdu.dart';
import 'messages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );


  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  MyApp({super.key});

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      title: 'AutiTrack',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: HomePage(),
      routes: {
        '/mainScreen': (context) => MainScreen(currentUserId: ''),
        '/mainScreenEdu': (context) => MainScreenEdu(currentUserId: ''),
        '/feedEdu': (context) => MainFeedPageEdu(currentUserId: ''),
        '/feedParent': (context) => MainFeedPageParent(currentUserId: ''),
        '/message': (context) => HomeScreen(  currentUserId: '',),
        '/messages': (context) => HomeScreenEdu(currentUserId: ''),
        '/graph': (context) => ThingSpeakGraph(),
        '/activity': (context) => MoodPage(currentUserId: ''),

        // Add other routes as needed
      },
    );
  }
}