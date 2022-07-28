import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'dart:async';
import 'package:simple_timer/simple_timer.dart';
import 'package:async/async.dart';

void main() {
  runApp(MyApp());
}

class FactStorage {
  Future<List<String>> readFile() async {
    try {
      // Read the file
      String path = "assets/facts.txt";
      List<String> contents =
          await rootBundle.loadStructuredData(path, (String s) async {
        return s.split('\n');
      });
      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return [];
    }
  }

  //Future<File> writeFile(List<String> facts) async {
  // final file = await _localFile;

  // Write the file
  //return file.writeAsString(facts.join('/n'));
  //}
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wisdom Teeth',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Wisdom Teeth'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final FactStorage storage = FactStorage();
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  String fact = "";
  bool buttonVisible = true;

  Timer _timer;
  TimerController _timerController;
  TimerStyle _timerStyle = TimerStyle.ring;
  TimerProgressIndicatorDirection _progressIndicatorDirection =
      TimerProgressIndicatorDirection.clockwise;
  TimerProgressTextCountDirection _progressTextCountDirection =
      TimerProgressTextCountDirection.count_down;

  @override
  void initState() {
    // initialize timercontroller
    _timerController = TimerController(this);
    super.initState();
  }

  void getFact() {
    widget.storage.readFile().then((List<String> facts) {
      _timer = new Timer(new Duration(seconds: 10), () {
        if (facts.isNotEmpty) {
          fact = facts.removeLast();
          getFact();
          writeFact();
        } else {
          fact = "No more facts, come back tomorrow";
          showButton();
        }
      });
    });
  }

  void writeFact() {
    setState(() {
      fact = fact;
    });
  }

  void showButton() {
    setState(() {
      buttonVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              fact,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: SimpleTimer(
                duration: const Duration(seconds: 120),
                controller: _timerController,
                timerStyle: _timerStyle,
                onStart: handleTimerOnStart,
                onEnd: handleTimerOnEnd,
                valueListener: timerValueChangeListener,
                backgroundColor: Colors.grey,
                progressIndicatorColor: Colors.green,
                progressIndicatorDirection: _progressIndicatorDirection,
                progressTextCountDirection: _progressTextCountDirection,
                progressTextStyle: TextStyle(color: Colors.black),
                strokeWidth: 10,
              ),
            )),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      onPressed: _timerController.start,
                      child: const Text("Start",
                          style: TextStyle(color: Colors.white)),
                      color: Colors.green,
                    ),
                    FlatButton(
                      onPressed: restart,
                      child: const Text("Restart",
                          style: TextStyle(color: Colors.white)),
                      color: Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void timerValueChangeListener(Duration timeElapsed) {}

  void restart() {
    print("timer restarting");
    _timer.cancel();
    _timerController.restart();
  }

  void handleTimerOnStart() {
    print("timer has just started");
    getFact();
  }

  void handleTimerOnEnd() {
    print("timer has ended");
    _timer.cancel(); //untested
  }
}
