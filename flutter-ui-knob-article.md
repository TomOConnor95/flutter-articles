# Flutter Tutorial - Custom User Input Knob using GuestureDetector

## Intro

[Flutter](https://flutter.dev/) is an open source portable UI toolkit made by Google, which is great for cross platform app development. From a single codebase you can deploy your code to iOS, Android, Desktop and Web (See [Hummingbird](https://flutter.dev/web)).
One of the great things about Flutter that no other cross platform app development tool can do is to define new custom UI elements using nothing but Dart code.
In this Flutter tutorial series I will demonstrate how easy it is to create your own custom UI elements from scratch.

------------------------------------------------------------------------------------------------------

A common UI element, especially in music software applications is a knob.

<img src="./massive.jpg" width="600"/>
<figcaption>The software synthesiser <a href="https://www.native-instruments.com/en/products/komplete/synths/massive/"><i>Massive</i></a>. Note the 31 Knobs in the UI</figcaption>

In [Flutter's widget catalogue](https://flutter.dev/docs/development/ui/widgets) there is no knob element for us to use out of the box, however it is easy to make your own (the full source code of mine is avaliable here (LINK)).

[do TLDR thing here]
<img src="./final-knob.png" width="300"/>[Make a gif version of this!]

Flutter already has a widget with a very similar behaviour to the one we are creating, the [`Slider` widget](https://api.flutter.dev/flutter/material/Slider-class.html) (you can see the full source code for Slider [on GitHub](https://github.com/flutter/flutter/blob/7a4c33425d/packages/flutter/lib/src/material/slider.dart#L91)).
The key difference between the slider and the knob we wish to create is visual: a slider converts a linear input guesture to a linear animation whereas the our knob will convert a linear input guesture to a rotational animation (You can also make a more life-like version a knob which uses rotational input guesture instead, and this will be covered in a future tutorial).

I will assume you have a basic knowledge of Flutter, Dart, Stateless and Stateful widgets, and have seen Flutter's "hello world" app, the `Counter App` (created by running the terminal command `flutter create .` or using the command `Flutter: New Project` in vscode). (See [this tutorial](https://flutterbyexample.com/dissecting-the-counter-app/) to get you started otherwise).

## Basic setup

We will start from a simple testbed for our new custom widget using a `Slider` widget, and a `Text` widget to display the slider's value. (TODO: Make a GIF instead of static image)

<img src="./slider-testbed.png" width="300"/>

The following code is based off the `Counter App` (See introduction).

File: `main.dart`

```
import 'package:flutter/material.dart';

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

  static const double _minValue = 0;
  static const double _maxValue = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Tutorial'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Slider(
              value: _value,
              onChanged: _setValue,
              min: _minValue,
              max: _maxValue,
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
```

In the `_MyHomePageState` widget's state we have a `_value` attribute used to store the current value of the slider and a `_setValue` function used by the slider to modify this value.

```
class _MyHomePageState extends State<MyHomePage> {
  double _value = 0.0;
  void _setValue(double value) => setState(() => _value = value);
  ...
```

The slider's interface is very simple. To use it, simply add it to the `_MyHomePageState` widget's `build` method, and pass it `_value` and `_setValue` as parameters. Setting the range of the slider is also straghtforward: pass in optional parameters for the min and max value.

```
Slider(
  value: _value,
  onChanged: _setValue,
  min: _minValue,
  max: _maxValue,
),
```

The `Text` widget is also passed `_value` as a parameter, however we round it to 3 decimal places.
```
Text(
  'Value: ${_value.toStringAsFixed(3)}',
),
```

## The design bit: Custom knob widget appearance

First we will design a simple knob. There are two approaches to making a new UI widget from scratch:
<div style="display flex">
  <img src="./composition-knob.png" width="170"/>
  <img src="./fancy-knob.gif" width="300"/>
</div>

- _Composing_ together other widgets (left). This is the easiest option, used here.
- Using the CustomPaint widget (right) to paint the widget at a low level out of lines, circles, arcs etc. This is the most powerful option and will be covered in a future tutorial.


We will make the knob out of a circle and an arrow icon. This can be customised much more and you can use whatever widget or design you want, but we'll keep it simple for now.

```
ClipOval(
  child: Container(
    color: Colors.blue,
    child: Icon(Icons.arrow_upward,
      color: Colors.white,
      size: 50,
    )
  )
),
```

## Simple behaviour: Custom Knob Widget - Continuous

In this tutorial we will make the knob respond to continuous values. The next tutorial will address discrete values which a bit trickier to handle.
There are two key parts to making a knob. Firstly we need the knob widget to respond to the `_value` attribute, and then we need to make it respond to the user input by calling `_setValue` method.

## Part 1: Visually respond to \_value

To make our knob rotate we can simply wrap it in a rotation widget.
It needs to rotate from a minimum angle to a maximum angle as the value changes from `_minValue_` to `_maxValue`.

To do this we will need to do a little bit of maths so let's import Dart's math library at the top of our file:

```
import 'dart:math';
```

This lets us use `pi` to get the value Pi (3.1415...)

As the arrow marker starts pointing vertically, set the minimum angle as -160° and the maximum angle as +160°. The total sweep angle is therefore 320° (See diagram). We want the final angle to be in radians.


We can use _linear interpolation_ to combine `minValue`, `maxValue` and `_value` to get a value between 0 and 1:
```
double _normalisedValue = (_value - minValue)/(maxValue - minValue)
```

Next use `_normalisedValue` variable calculate the desired angle. We are again using linear interpolation to convert to an angle in degrees, then multiplying by `2 * pi /360` to convert to radians.

```
double _angle = (minAngle + (_normalisedValue*(sweepAngle)) * 2 * pi / 360;
```

<img src="./linear_interpolation.png" width="700"/>

 we can do the calculation at the start of the build method:
```
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
    double _normalisedValue = (_value - minValue)/(maxValue - minValue)
    double _angle = ((minAngle + (_normalisedValue*(sweepAngle))) / 360) * 2 * pi;
    return Scaffold(
      ...
```

We can then simply wrap our widgets in a `Transform.rotate()` widget, and simply pass it our new computed angle:

```
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
```

Now if we move the slider, our knob should respond correctly.
(GIF) [Link to full source code up to here]
This pattern of using a slider (or several sliders) to test the behaviour of another UI element is very useful when testing the new UI element, as it allows you to get the visual behaviour correct before working on the actual user input.

## Part 2: Respond to user input

In this section we will make the knob actually respond to being dragged. We will make the knob such that it rotates when the user drags it in a vertical direction (More complicated behaviours are possible, such as making the knob rotate as the user drags in a circle around it, or adding momentum and viscocity to the knob, but we'll save these for another time).

The first step is to wrap our knob in a GestureDetector, and provide a onVerticalDragUpdate function which sets what happens when the user drags the knob in a vertical direction.

```
Transform.rotate(
  angle: _angle,
  child: GestureDetector(
    onVerticalDragUpdate: (DragUpdateDetails details) {
      double changeInY = details.delta.dy;
      print(changeInY);
      // Respond to the changeInY
    },
    child: ClipOval(
      ...
    ),
  ),
),
```

Now when you drag on the knob, you should see values being printed in the debug console. The values represent the number of pixels that you have moved. You'll notice that dragging upwards gives a negatve value, so we need to account for this by changing the logic to `double changeInY = -details.delta.dy;`
(See GIF)

Now we need to use these `changeInY` value to actually change the angle. The steps are as follows:

- Convert the `changeInY` value to a change in `_value`.
- Add this `changeInValue` to the current value.
- Limit the resulting value to be between 0 and 1.
- call `_setValue` with the new value

And here is how to acheive this in the code:

-------------------------------------------------------------------------------

Define a constant `distanceToAngle` which is the number needed to map from `changeInY` to `changeInValue`:

```
class _MyHomePageState extends State<MyHomePage> {
  ...
  static const double distanceToAngle = 0.007;
  ...
```

Now we use this in the `onVerticalDragUpdate` method:

```
onVerticalDragUpdate: (DragUpdateDetails details) {
  double changeInY = - details.delta.dy;
  double changeInValue = distanceToAngle * changeInY; // Note the negative sign
  double newValue = _value + changeInValue;
  double clippedValue = min(max(newValue, 0), 1);

  _setValue(clippedValue)
},
```

Now we have enerything set up! Drag the knob and see that the value changes correctly!

Now that we have a fully functioning knob, let's tidy up our code and move the knob into its own component.

### Moving the knob into a Stateless Component



## other ideas...

### Make background for knob with ticks??

### Bonus: Use \_value to add more styling to knob??

Show changing the border thickness of the knob

### Bonus: Put use GIF for knobface??

# Blog article pt.2 make the knob handle interger values?

In the previous article we made a simple knob that handles continuous input values, using a stateless widget and a guesture detector.

In this article we will make the knob handle integer values. Do do this our knob now needs some internal state: we need to store a continuous internal value for display purposes.
