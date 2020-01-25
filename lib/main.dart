import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum ModeOfOperation { one, two }
AudioPlayer audioPlayer = AudioPlayer();
AudioCache audioCache = new AudioCache();

class _MyHomePageState extends State<MyHomePage> {
  static AssetImage _imageBlackOk = AssetImage('assets/images/Black_OK.PNG');
  static AssetImage _imageBlackAlarm =
      AssetImage('assets/images/Black_Alarm.PNG');
  static AssetImage _imageBlackDisconnect =
      AssetImage('assets/images/Black_Disconnect.PNG');
  static AssetImage _imageBlack = _imageBlackDisconnect;
  static AssetImage _imageWhiteOk = AssetImage('assets/images/White_OK.PNG');
  static AssetImage _imageWhiteAlarm =
      AssetImage('assets/images/White_Alarm.PNG');
  static AssetImage _imageWhiteDisconnect =
      AssetImage('assets/images/White_Disconnect.PNG');
  static AssetImage _imageWhite = _imageWhiteDisconnect;
  ModeOfOperation currentMode = ModeOfOperation.one;
  String dropdownValue = 'Option 1';
  List<int> whiteOutputState = new List(10);
  List<int> blackOutputState = new List(10);
  List<String> progNames = [
    "Option 1",
    "Option 2",
    "Option 3",
    "Option 4",
    "Option 5"
  ];
  List<TextEditingController> progControllers = new List(5);
  static Socket socket1;
  static Socket socket2;
  static num watchdog1 = 0;
  static num watchdog2 = 0;
  String data1 = " ";
  String data2 = " ";
  String ddValue = "Option 1";
  static bool connected1 = false;
  static bool connected2 = false;
  Color conColor = Colors.white;
  Color disColor = Colors.white;
  //String picBlackOk='assets/images/Black_OK.PNG';
  static int count = 1;
  static const oneSec = const Duration(seconds: 1);
  static const twoSec = const Duration(seconds: 2);
  static const halfSec = const Duration(milliseconds: 500);
  //Timer timerProg;
  Timer timerProg;
  Timer timerProg2;
  static bool disTrig1 = false;
  static bool disTrig2 = false;
  Timer watchDogErrorTimer = Timer.periodic(twoSec, (watchDogErrorTimer) {
    watchDogTester();
  });

  bool _isPlaying = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: //Text(data1 == null ? 'NO CONNECTED1' : 'CONNECTED1'),
            const Text("Sick App"),
        actions: <Widget>[
          FlatButton(
            textColor: conColor,
            onPressed: () {
              connect();
            },
            child: const Text("Connect"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
          FlatButton(
            textColor: disColor,
            onPressed: () {
              disconnect();
            },
            child: const Text("Disconnect"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Rear",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Material(
                      child: InkWell(
                        onTap: () {
                          _stop();
                        },
                        child: Container(
                          height: 200,
                          width: 200,
                          padding: EdgeInsets.all(10),
                          child: Image(
                            image: _imageBlack,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Front",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Material(
                      child: InkWell(
                        onTap: () {
                          _stop();
                        },
                        child: Container(
                          height: 200,
                          width: 200,
                          padding: EdgeInsets.all(10),
                          child: Image(
                            image: _imageWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                DropdownButton<String>(
                  value: ddValue,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String newValue) {
                    ddValue = newValue;
                    _showDialogMode(false, ModeOfOperation.one, newValue);
                    //   setState(() {
                    //     dropdownValue = newValue;
                    //     print("the new value is $dropdownValue");
                    //    });
                  },
                  items:
                      progNames.map<DropdownMenuItem<String>>((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ListTile(
                    title: Text(
                      'Full Area',
                      textAlign: TextAlign.right,
                    ),
                    trailing: Radio(
                      value: ModeOfOperation.one,
                      groupValue: currentMode,
                      onChanged: (ModeOfOperation value) {
                        _showDialogMode(true, value, "");
                        //   setState(() {
                        //     currentMode = value;
                        //     print("the new value is $currentMode");
                        //   });
                      },
                    )),
                ListTile(
                    title: Text(
                      'Limited Area',
                      textAlign: TextAlign.right,
                    ),
                    trailing: Radio(
                      value: ModeOfOperation.two,
                      groupValue: currentMode,
                      onChanged: (ModeOfOperation value) {
                        _showDialogMode(true, value, "");
                        //     setState(() {
                        //       currentMode = value;
                        //      print("the new value is $currentMode");
                        //      });
                      },
                    )),

                // RaisedButton(
                //   child: Text('Stop'),
                //   onPressed: () {},
                // ),
              ],
            ),
            RaisedButton(
              child: Text('mute'),
              onPressed: () {
                _stop();
              },
            ),
            RaisedButton(
              child: Text('change Program Names'),
              onPressed: () {
                _changeProgramNames();
              },
            ),
          ],
        ),
      ),
    );
  }

  _play(String trackName) async {
    //audioPlayer.
    audioPlayer = await audioCache.play(trackName);
    //  setState(() {

    //   });
  }

  void _stop() {
    //print("stopping");
    audioPlayer?.stop();
    //audioPlayer?.stop();
    _isPlaying = false;
  }

  // Socket connection
  void connect() {
    // Socket.startConnect(host, port)
    Socket.connect("192.168.0.10", 2111, timeout: twoSec).then((Socket sock1) {
      socket1 = sock1;
      socket1.listen(dataHandler1,
          onError: errorHandler1, onDone: doneHandler1, cancelOnError: false);
    });

    Socket.connect("192.168.0.11", 2111, timeout: twoSec).then((Socket sock2) {
      socket2 = sock2;
      socket2.listen(dataHandler2,
          onError: errorHandler2, onDone: doneHandler2, cancelOnError: false);
    });

    // if ((socket1 != null) && (socket2 != null)) {
    print("connecting");
    timerProg = Timer.periodic(oneSec, (timerProg) {
      //sendDataTime();
    });
    timerProg2 = Timer.periodic(oneSec, (timerProg2) {
      sendData();
    });
    //  }
    //else {
    //   setState(() {
    //    data1 = "error communicating with sensors!";
    //   });
    // }
  }

  void disconnect() {
    // socket1.destroy();
    // socket2.destroy();
    connected1 = false;
    connected2 = false;
    timerProg.cancel();
    timerProg2.cancel();
    // timerProg = null;
    // timerProg2 = null;
    while (timerProg.isActive) {}
    while (timerProg2.isActive) {}
    socket1.close();
    socket2.close();
    //  socket1 = null;
    //  socket2 = null;
    conColor = Colors.white;
    _imageWhite = _imageWhiteDisconnect;
    _imageBlack = _imageBlackDisconnect;
  }

  void dataHandler1(data) {
    setState(() {
      //print("watchdog1: $watchdog1");
      if (data != null) {
        data1 = new String.fromCharCodes(data).trim();
        if (data1.contains("sRA STlms")) {
          //    print("new TIMER1 received");
          //print(data1);
        } else if (data1.contains("LIDoutputstate")) {
          watchdog1 = 1;
          connected1 = true;
          disTrig1 = false;
          conColor = Colors.green;
          //    print("new OUTPUT1 received");
          print("Data1: $data1");
          List<String> lastreceived1 = data1.split(" ");
          int count = 0;
          for (var i = 0; i < 20; i = i + 2) {
            blackOutputState[count] = int.parse(lastreceived1[i + 4]);
            count++;
          }
          int prog = int.parse((dropdownValue.split(" "))[1]);
          if (blackOutputState[prog - 1] == 1)
          //al is ok. prog number equals program selected
          {
            //  print("OK1");
            if (_imageBlack != _imageBlackOk) {
              changePicBlack(_imageBlackOk);
              _stop();
            }
          } else {
            print("ALARM1");
            //trigger alarm and change image!
            if (_imageBlack != _imageBlackAlarm) {
              changePicBlack(_imageBlackAlarm);
              if (!_isPlaying) {
                _isPlaying = true;
                _play('sounds/alarm2.mp3');
              }
            }
          }
        }
      }
    });
  }

  void errorHandler1(error, StackTrace trace) {
    setState(() {
      data1 = "Error communiacting Sensor1";
      print("error1");
      print(error);
      conColor = Colors.white;
    });
  }

  void doneHandler1() {
    setState(() {
      _imageBlack = _imageBlackDisconnect;
      data1 = "Closed communiaction Sensor1";
      connected1 = false;
      print("done handler1");
      socket1.destroy();
      conColor = Colors.white;
    });
  }

  void dataHandler2(data) {
    setState(() {
      //print("watchdog2: $watchdog2");
      if (data != null) {
        data2 = new String.fromCharCodes(data).trim();
        if (data2.contains("sRA STlms")) {
          // print("new TIMER2 received");
          //  print(data2);
        } else if (data2.contains("LIDoutputstate")) {
          watchdog2 = 1;
          connected2 = true;
          disTrig2 = false;
          conColor = Colors.green;
          // print("new OUTPUT2 received");
          print("Data2: $data2");
          List<String> lastreceived2 = data2.split(" ");
          //  for (var i =0; i<lastreceived2.length; i++ ) {print(lastreceived2[i]);}
          int count = 0;
          for (var i = 0; i < 20; i = i + 2) {
            whiteOutputState[count] = int.parse(lastreceived2[i + 4]);
            //   print("$count: ${(whiteOutputState[count]).toString()} : ${(lastreceived2[i + 2])}");
            count++;
          }
          //  print("list:");
          //   for (var i = 0; i < 10; i++) {
          //  print("$i : ${whiteOutputState[i].toString()}");}
          int prog = int.parse((dropdownValue.split(" "))[1]);
          prog *= 2;
          currentMode == ModeOfOperation.one ? prog -= 1 : prog -= 0;
          //  print(prog);
          if (whiteOutputState[prog - 1] == 1)
          //al is ok. prog number equals program selected
          {
            //  print("OK2");
            if (_imageWhite != _imageWhiteOk) {
              _stop();
              changePicWhite(_imageWhiteOk);
            }
          } else {
            print("ALARM2");
            //trigger alarm and change image!
            if (_imageWhite != _imageWhiteAlarm) {
              if (!_isPlaying) {
                _isPlaying = true;
                _play('sounds/alarm2.mp3');
              }
              changePicWhite(_imageWhiteAlarm);
            }
          }
        }
      }
    });
  }

  void errorHandler2(error, StackTrace trace) {
    setState(() {
      data2 = "Error communiacting Sensor2";
      print(error);
      print("error2");
      conColor = Colors.white;
    });
  }

  void doneHandler2() {
    setState(() {
      _imageWhite = _imageWhiteDisconnect;
      data2 = "Closed communiaction Sensor2";
      connected2 = false;
      socket2.destroy();
      print("done handler2");
      conColor = Colors.white;
    });
  }

  static void sendData() {
    try {
      String message = String.fromCharCode(2) +
          "sRN LIDoutputstate" +
          String.fromCharCode(3);
      if (socket1 != null) socket1.write(message);
      watchdog1 += 1;
      if (socket2 != null) socket2.write(message);
      watchdog2 += 1;
    } catch (e) {
      print("error =>" + e.toString());
    }
  }

  void sendDataTime() {
    String message =
        String.fromCharCode(2) + "sRN STlms" + String.fromCharCode(3);
    socket1.write(message);
    socket2.write(message);
  }

  static void watchDogTester() {
    if (watchdog1 > 2) {
      print("LIDAR1 disconnected! time off = $watchdog1");
      connected1 = false;
      _imageBlack = _imageBlackDisconnect;
      if (!disTrig1) {
        audioCache.play('sounds/siren.mp3');
        disTrig1 = true;
      }
    }
    if (watchdog2 > 2) {
      print("LIDAR2 disconnected! time off = $watchdog2");
      connected2 = false;
      _imageWhite = _imageWhiteDisconnect;
      if (!disTrig2) {
        audioCache.play('sounds/siren.mp3');
        disTrig2 = true;
      }
    }
  }

  void changePicBlack(AssetImage ai) {
    setState(() {
      _imageBlack = ai;
      //  _imageWhite = _imageWhiteAlarm;
    });
  }

  void changePicWhite(AssetImage ai) {
    setState(() {
      _imageWhite = ai;
      //  _imageWhite = _imageWhiteAlarm;
    });
  }

  void _showDialogMode(bool type, ModeOfOperation mode, String dropDown) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(type ? 'Change Mode' : 'Change Program'),
          content: new Text("Are you sure you want to change this setting?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                if (type) {
                  setState(() {
                    currentMode = mode;
                    print("the new mode is $currentMode");
                  });
                } else {
                  setState(() {
                    dropdownValue = dropDown;
                    print("the new Drop Down value is $dropdownValue");
                  });
                }
              },
            ),

            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _changeProgramNames() {
    List<String> tempNames = progNames;

    int index = progNames.indexOf(ddValue);

    showDialog(
        context: context,
        barrierDismissible:
            false, // dialog is dismissible with a tap on the barrier
        builder: (BuildContext context) {
          return AlertDialog(
            //  contentPadding: const EdgeInsets.all(16.0),
            title: Text('Enter new program names'),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    textAlign: TextAlign.start,
                    expands: false,
                    autofocus: true,
                    decoration: new InputDecoration(
                        labelText: progNames[0], hintText: 'eg. Program no. 1'),
                    onChanged: (value) {
                      tempNames[0] = value;
                    },
                  ),
                  TextField(
                    textAlign: TextAlign.start,
                    expands: false,
                    autofocus: true,
                    decoration: new InputDecoration(
                        labelText: progNames[1], hintText: 'eg. Program no. 2'),
                    onChanged: (value) {
                      tempNames[1] = value;
                    },
                  ),
                  TextField(
                    textAlign: TextAlign.start,
                    expands: false,
                    autofocus: true,
                    decoration: new InputDecoration(
                        labelText: progNames[2], hintText: 'eg. Program no. 3'),
                    onChanged: (value) {
                      tempNames[2] = value;
                    },
                  ),
                  TextField(
                    textAlign: TextAlign.start,
                    expands: false,
                    autofocus: true,
                    decoration: new InputDecoration(
                        labelText: progNames[3], hintText: 'eg. Program no. 4'),
                    onChanged: (value) {
                      tempNames[3] = value;
                    },
                  ),
                  TextField(
                    textAlign: TextAlign.start,
                    expands: false,
                    autofocus: true,
                    decoration: new InputDecoration(
                        labelText: progNames[4], hintText: 'eg. Program no. 5'),
                    onChanged: (value) {
                      tempNames[4] = value;
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Save'),
                onPressed: () {
                  //  for (var i = 0; i < 5; i = i + 1) {
                  //     print(progNames[i]);
                  //    }
                  setState(() {
                    try {
                      ddValue = tempNames[index];
                      progNames = tempNames;
                    } catch (e) {
                      print("error =>" + e.toString());
                    }
                  });
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
