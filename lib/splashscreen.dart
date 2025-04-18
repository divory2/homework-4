import 'package:flutter/material.dart';
import 'package:homework_4/main.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MyHomePage(title: "Firebase Auth Demo")),
      );
    });

    return Scaffold(
      body: Center(child: Text("Welcome to Chat App")),
    );
  }
}
