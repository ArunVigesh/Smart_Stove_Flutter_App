import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:firebase_database/firebase_database.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Body(),
      ),
    );
  }
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final databaseReference = FirebaseDatabase.instance.reference();
  int hour = 0;
  int min = 0;
  int sec = 0;
  bool started = true;
  bool stopped = true;
  int timeForTimer = 0;
  String timeToDisplay = "";
  bool checkTimer = true;

  void start() {
    setState(() {
      started = false;
      stopped = false;
    });
    timeForTimer = (hour * 60 * 60) + (min * 60) + (sec);
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
//          Navigator.pushReplacement(
//              context,
//              MaterialPageRoute(
//                builder: (context) => MyApp(),
//              ));
        } else if (timeForTimer < 60) {
          databaseReference.reference().update({'c': '{\"A\":$timeForTimer}'});
          timeToDisplay = "Time Left  " + timeForTimer.toString();
          timeForTimer = timeForTimer - 1;
        } else if (timeForTimer < 3600) {
          databaseReference.reference().update({'c': '{\"A\":$timeForTimer}'});
          int m = timeForTimer ~/ 60;
          int s = timeForTimer - (60 * m);
          timeToDisplay = "Time Left  " + m.toString() + ":" + s.toString();
          timeForTimer = timeForTimer - 1;
        } else {
          databaseReference.reference().update({'c': '{\"A\":$timeForTimer}'});
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
      databaseReference.reference().update({'c': '{\"A\":0.0}'});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Image(
            image: AssetImage('images/vessel.png'),
            height: 150.0,
            width: 300.0,
          ),
          Image(
            image: AssetImage('images/fire.png'),
            height: 50,
            width: 200,
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
                  child: Image(
                    image: AssetImage('images/circle.png'),
                    height: 65,
                    width: 65,
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
          )
        ],
      ),
    );
  }
}
