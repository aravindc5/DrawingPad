import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DrawingArea> points = [];
  Color pickerColor;
  double strokeWidth;
  @override
  void initState() {
    super.initState();
    strokeWidth = 2.0;
    pickerColor = Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    void selectColor() {
      showDialog(
        context: context,
        child: AlertDialog(
          title: const Text('Color Chooser'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                this.setState(() {
                  pickerColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"))
          ],
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Colors.deepPurple[400],
                    Colors.deepPurple[100],
                    Colors.deepPurple[600],
                  ])),
            ),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: width * 0.90,
                      height: height * 0.85,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 5.0,
                              spreadRadius: 1.0,
                            )
                          ]),
                      child: GestureDetector(
                          onPanDown: (details) {
                            this.setState(() {
                              points.add(DrawingArea(
                                  point: details.localPosition,
                                  areaPaint: Paint()
                                    ..strokeCap = StrokeCap.round
                                    ..isAntiAlias = true
                                    ..color = pickerColor
                                    ..strokeWidth = strokeWidth));
                            });
                          },
                          onPanUpdate: (details) {
                            this.setState(() {
                              points.add(DrawingArea(
                                  point: details.localPosition,
                                  areaPaint: Paint()
                                    ..strokeCap = StrokeCap.round
                                    ..isAntiAlias = true
                                    ..color = pickerColor
                                    ..strokeWidth = strokeWidth));
                            });
                          },
                          onPanEnd: (details) {
                            this.setState(() {
                              points.add(null);
                            });
                          },
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                            child: CustomPaint(
                              painter: MyCustomPainter(points: points),
                            ),
                          )),
                    ),
                  ),
                  Container(
                    width: width * 0.80,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.color_lens,
                            color: pickerColor,
                          ),
                          onPressed: selectColor,
                        ),
                        Expanded(
                          child: Slider(
                            min: 1.0,
                            max: 20.0,
                            value: strokeWidth,
                            activeColor: pickerColor,
                            onChanged: (value) {
                              this.setState(() {
                                strokeWidth = value;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.layers_clear,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            this.setState(() {
                              points.clear();
                            });
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  List<DrawingArea> points;

  MyCustomPainter({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint color = Paint()..color = Colors.white;
    Rect rectangleArea = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rectangleArea, color);
    canvas.clipRect(rectangleArea);

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
            points[i].point, points[i + 1].point, points[i].areaPaint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(
            PointMode.points, [points[i].point], points[i].areaPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class DrawingArea {
  Offset point;
  Paint areaPaint;

  DrawingArea({this.point, this.areaPaint});
}
