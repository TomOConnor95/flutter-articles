import 'package:flutter/material.dart';

import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _value = 0.0;
  void _setvalue(double value) => setState(() => _value = value);

  static const double minAngle = -160;
  static const double maxAngle = 160;
  static const double sweepAngle = maxAngle - minAngle;

  static const double distanceToAngle = 0.007;


  @override
  Widget build(BuildContext context) {
    double _angle = (((_value*320) - 160) / 360) * 2 * pi;
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Tutorial'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Transform.rotate(
              angle: _angle, 
              child: GestureDetector(
                onVerticalDragUpdate: (DragUpdateDetails details) {
                  double changeInY = - details.delta.dy;
                  print(changeInY);
                  double changeInValue = distanceToAngle * changeInY;
                  double newValue = _value + changeInValue;
                  double clippedValue = min(max(newValue, 0), 1);
  
                  _setvalue(clippedValue);
                },
                child: ClipOval(
                  child: Container(
                    color: Colors.blue,
                    child: Icon(Icons.arrow_upward,
                      color: Colors.white,
                      size: 50,
                    )
                  )
                ),
              ),
            ),
            Slider(value: _value, onChanged: _setvalue),
            Text(
              'Value: ${_value.toStringAsFixed(3)}',
            ),
          ],
        ),
      ),
    );
  }
}
