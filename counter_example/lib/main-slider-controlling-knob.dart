import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _value = 0.0;  
  void _setValue(double value) => setState(() => _value = value);

  static const double minValue = 0;
  static const double maxValue = 10;


  static const double minAngle = -160;
  static const double maxAngle = 160;
  static const double sweepAngle = maxAngle - minAngle;

  @override
  Widget build(BuildContext context) {
    double _normalisedValue = (_value - minValue)/(maxValue - minValue);
    double _angle = (minAngle + _normalisedValue * sweepAngle) / 360 * 2 * pi;

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
            Slider(
              value: _value,
              onChanged: _setValue,
              min: minValue,
              max: maxValue,
            ),
            Text(
              'Value: ${_value.toStringAsFixed(3)}',
            ),
          ],
        ),
      ),
    );
  }
}