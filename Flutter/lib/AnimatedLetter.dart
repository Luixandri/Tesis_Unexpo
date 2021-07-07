import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

// Se encarga de la animacion del texto "ON/OFF Luces"

class Letter extends StatefulWidget {
  @override
  LetterState createState() => LetterState();
}

class LetterState extends State<Letter> {

 @override
  
  Widget build(BuildContext context) {
    const colorizeColors = [
  Colors.green,
  Colors.purple,
  Colors.blue,
  Colors.yellow,
  Colors.white,
];

const colorizeTextStyle = TextStyle(
  fontSize: 20.0,
  fontFamily: 'Horizon',
  letterSpacing: 4,
  fontWeight: FontWeight.w600,
);

return SizedBox(
  width: 500.0,
  child: AnimatedTextKit(
    animatedTexts: [
      ColorizeAnimatedText(
        'ON/OFF Leds House',
        textStyle: colorizeTextStyle,
        colors: colorizeColors,
        textAlign: TextAlign.start,
        speed: const Duration(seconds:1)
      ),
    ],
    isRepeatingAnimation: true,
    onTap: () {
      print("Tap Event");
    },
  ),
);
  }
}
