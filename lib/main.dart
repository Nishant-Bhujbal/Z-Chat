import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:zchat/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

late Size mq;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // for system to be always in potrait
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then(
    (value) {
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      fluuterNotificationChannel();
      runApp(const MyApp());
    },
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Z-Chat',
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        titleTextStyle: TextStyle(
            color: Colors.black, fontWeight: FontWeight.normal, fontSize: 25),
        backgroundColor: Colors.white,
      )),
      home: const SplashScreen(),);
  }

}

void fluuterNotificationChannel() async{
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For showing message notification ',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
);
log("this is result notificatio re baba $result");
}
