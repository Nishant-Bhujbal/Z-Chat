import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zchat/api/apis.dart';
import 'package:zchat/auth/login_screen.dart';
import 'package:zchat/screens/home_screen.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    //for auto triggering animation
    Future.delayed(const Duration(milliseconds: 1500), () {

      //exit full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: Colors.white));

          // if user is known move to home or move to login
          if(Apis.auth != null){
             Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          }
          else{
             Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginScreen()));
          }

          
    });
  }

  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        //app logo
        Positioned(
            top: mq.height * .15,
            right: mq.width * .25,
            width: mq.width * .5,
            child: Image.asset('assets/login_icon.png')),

        //google login button
        Positioned(
            bottom: mq.height * .25,
            width: mq.width,
            child: Text(
              "MADE IN INDIA WITH 💖",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            )),
      ]),
    );
  }
}
