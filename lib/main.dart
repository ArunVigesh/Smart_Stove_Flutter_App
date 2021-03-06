import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:firebase_database/firebase_database.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Body(),
        ),
      ),
    );
  }
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  void initState() {
    super.initState();
    vesselVisible();
    flameVisible();
    setKnobAngle();
  }

  final databaseReference = FirebaseDatabase.instance.reference();
  int hour = 0;
  int min = 0;
  int sec = 0;
  bool started = true;
  bool stopped = true;
  int timeForTimer = 0;
  String timeToDisplay = "";
  bool checkTimer = true;
  bool vessel = true;
  bool flame = true;
  double knobAngle = -pi / 4;

  void start() {
    setState(() {
      started = false;
      stopped = false;
    });
    timeForTimer = (hour * 60 * 60) + (min * 60) + (sec);
    databaseReference.reference().update({'a': '{\"A\":$timeForTimer}'});
    Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (timeForTimer < 1 || checkTimer == false) {
          t.cancel();
          if (timeForTimer == 0) {
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text("Turned OFF"),
            ));
            databaseReference.reference().update({'c': '{\"K\":0.0}'});
          }
          checkTimer = true;
          timeToDisplay = "";
          started = true;
          stopped = true;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MyApp(),
              ));
        } else if (timeForTimer < 60) {
          databaseReference.reference().update({'a': '{\"A\":-1}'});
          timeToDisplay = "Time Left  " + timeForTimer.toString();
          timeForTimer = timeForTimer - 1;
        } else if (timeForTimer < 3600) {
          databaseReference.reference().update({'a': '{\"A\":-1}'});
          int m = timeForTimer ~/ 60;
          int s = timeForTimer - (60 * m);
          timeToDisplay = "Time Left  " + m.toString() + ":" + s.toString();
          timeForTimer = timeForTimer - 1;
        } else {
          databaseReference.reference().update({'a': '{\"A\":-1}'});
          int h = timeForTimer ~/ 3600;
          int t = timeForTimer - (3600 * h);
          int m = t ~/ 60;
          int s = t - (60 * m);
          timeToDisplay = "Time Left  " +
              h.toString() +
              ":" +
              m.toString() +
              ":" +
              s.toString();
          timeForTimer = timeForTimer - 1;
        }
      });
    });
  }

  void stop() {
    setState(() {
      started = true;
      stopped = true;
      checkTimer = false;
      databaseReference.reference().update({'a': '{\"A\":0.0}'});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 16.0,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 16.0,
                ),
                FlatButton(
                  child: Image(
                    image: AssetImage('images/mobile-calibration.png'),
                    height: 50.0,
                  ),
                ),
                Text(
                  "☜ Calibrate",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                )
              ],
            ),
            Text(
              "Smart Stove",
              style: TextStyle(
                  fontSize: 32.0,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent),
            ),
            Text(
              "`Your Stove` in `Your Hands`",
              style: TextStyle(
                  fontSize: 16.0,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue),
            ),
            SizedBox(
              height: 30,
            ),
            Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: vessel,
              child: Image(
                image: AssetImage('images/vessel.png'),
                height: 150.0,
                width: 300.0,
              ),
            ),
            Visibility(
              visible: flame,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Image(
                image: AssetImage('images/fire.png'),
                height: 50,
                width: 200,
              ),
            ),
            Stack(
              children: <Widget>[
                Center(
                  child: Image(
                    image: AssetImage('images/stove.png'),
                    height: 120,
                    width: 300,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 45.0),
                  child: Center(
                    child: Transform.rotate(
                      angle: knobAngle,
                      child: Image(
                        image: AssetImage('images/circle.png'),
                        height: 65,
                        width: 65,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              onPressed: () {
                databaseReference.reference().update({'c': '{\"K\":0.0}'});
              },
              padding: EdgeInsets.all(16.0),
              color: Colors.deepOrange,
              child: Text(
                "Turn OFF",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        "HH",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    NumberPicker.integer(
                        initialValue: hour,
                        minValue: 0,
                        maxValue: 23,
                        onChanged: (val) {
                          setState(() {
                            hour = val;
                          });
                        })
                  ],
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        "MM",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    NumberPicker.integer(
                        initialValue: min,
                        minValue: 0,
                        maxValue: 59,
                        listViewWidth: 50.0,
                        onChanged: (val) {
                          setState(() {
                            min = val;
                          });
                        })
                  ],
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        "SS",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    NumberPicker.integer(
                        initialValue: sec,
                        minValue: 0,
                        maxValue: 59,
                        onChanged: (val) {
                          setState(() {
                            sec = val;
                          });
                        })
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 25.0,
            ),
            Text(
              timeToDisplay,
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(
              height: 25.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  color: Colors.green[100],
                  onPressed: started ? start : null,
                  child: Text("Start"),
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  color: Colors.red[100],
                  onPressed: stopped ? null : stop,
                  child: Text("Stop"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void vesselVisible() {
    databaseReference.onChildChanged.listen((event) {
      databaseReference.once().then((DataSnapshot snap) {
        if (jsonDecode(snap.value['s'])['D'] == 1) {
          setState(() {
            vessel = true;
          });
        } else {
          setState(() {
            vessel = false;
          });
        }
      });
    });
  }

  void flameVisible() {
    databaseReference.onChildChanged.listen((event) {
      databaseReference.once().then((DataSnapshot snap) {
        if (jsonDecode(snap.value['s'])['G'] == 0) {
          setState(() {
            flame = false;
          });
        } else {
          setState(() {
            flame = true;
          });
        }
      });
    });
  }

  void setKnobAngle() {
    databaseReference.onChildChanged.listen((event) {
      databaseReference.once().then((DataSnapshot snap) {
        if (jsonDecode(snap.value['s'])['K'] > 0) {
          var k = jsonDecode(snap.value['s'])['K'];
          setState(() {
            knobAngle =
                ((jsonDecode(snap.value['s'])['K']) * pi / 180) - pi / 4;
          });
          databaseReference.reference().update({'c': '{\"K\":$k}'});
        } else {
          setState(() {
            knobAngle = -pi / 4;
          });
        }
      });
    });
  }
}
