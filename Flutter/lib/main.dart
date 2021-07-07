import 'package:flutter/material.dart';
import 'Header.dart';

final List<bool> auxiliar= [false, false];
  void main() => runApp(MyApp());

 
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tesis UNEXPO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Header (),
   );
  }
}
