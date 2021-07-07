import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'Back.dart';
import 'Fila.dart';
import 'bluetooh.dart';

//Header cumple la funcion de Encabezado y estructura de la app

class Header extends StatefulWidget {
  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> { 
   @override
  Widget build(BuildContext context) {

    return new Scaffold(
      endDrawer: Drawer(
        child: new WifiSetter(),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFF973CD7),
        title: Image.asset(
          "assets/images/unexpo.png",
          height: 40.0,
          ),
          ),
    
      body: new Stack (
        children: <Widget>[
          new BackWheater(), 
          new Fila1(),
        ],
        ) 
      ); 
  }
}

