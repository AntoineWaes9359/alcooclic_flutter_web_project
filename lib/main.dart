import 'constant.dart';
import 'package:flutter/material.dart';
import 'Screens/Accueil.dart';
// main.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alcooclic',
      theme: ThemeData(
        primaryColor: couleurBleu,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Accueil(),
    );
  }
}
