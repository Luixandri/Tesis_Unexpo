import 'package:flutter/material.dart';

// Back se encarga del estilo de los recuadros de fondo de la app

class BackWheater extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new GradientBack(),
        new Positioned(
          bottom: 0.0,
          child: new Container(
            width:  MediaQuery.of(context).size.width,
            height: 175.0,
            color : Colors.white,
          )
        ),
      ],
      );
  }
}

class GradientBack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container (
      decoration: new BoxDecoration(
          color: 
            Color(0xFFDCBBF2) 
        )

      );
  }
}
