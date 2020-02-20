import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import './files.dart';
import 'package:screen/screen.dart';
import 'package:hardware_buttons/hardware_buttons.dart' as HardwareButtons;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Sick Sensors App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum ModeOfOperation { one, two }
AudioPlayer audioPlayer = AudioPlayer();
AudioCache audioCache = new AudioCache();
AudioPlayer advancedPlayer;

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription<HardwareButtons.LockButtonEvent> _lockButtonSubscription;
  static bool locked = false;
  static bool lockDetected = false;
  final ProgStorage storage = new ProgStorage();
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
  bool isKeptOn;
  static Socket socket1;
  static Socket socket2;
  static num watchdog1 = 0;
  static num watchdog2 = 0;
  static num eternalWD1 = 0;
  static num eternalWD2 = 0;
  String data1 = " ";
  String data2 = " ";
  String ddValue = "Option 1";
  static bool connected1 = false;
  static bool connected2 = false;
  static bool alarm1 = false;
  static bool alarm2 = false;
  Color conColor1 = Colors.white;
  Color conColor2 = Colors.white;
  Color disColor = Colors.white;
  //String picBlackOk='assets/images/Black_OK.PNG';
  static int count = 1;
  static const oneSec = const Duration(seconds: 1);
  static const twoSec = const Duration(seconds: 2);
  static const tenSec = const Duration(seconds: 10);
  static const halfSec = const Duration(milliseconds: 500);
  //Timer timerProg;
  Timer timerProg;
  Timer timerProg1;
  Timer timerProg2;
  static bool disTrig1 = false;
  static bool disTrig2 = false;
  static bool reconnect1 = false;
  static bool reconnect2 = false;
  Timer watchDogErrorTimer;

  bool oneisDouble;
  DateTime dtOne = DateTime.now();
  bool twoisDouble;
  DateTime dtTwo;

  // bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
     Screen.setBrightness(1);
    locked = false;
    dtTwo = dtOne.add(tenSec);
    _lockButtonSubscription =
        HardwareButtons.lockButtonEvents.listen(_lockWasDetected);
    SystemChrome.setEnabledSystemUIOverlays([]);
    //progNames = storage.readNames();
    advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);
    storage.readNames().then((List<String> names) {
      setState(() {
        for (var i = 0; i < names.length; i = i + 1) {
          print(names[i]);
        }
        ddValue = names[0];
        progNames = names;
      });
    });
    watchDogErrorTimer = Timer.periodic(twoSec, (watchDogErrorTimer) {
      watchDogTester();
    });
    connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: //Text(data1 == null ? 'NO CONNECTED1' : 'CONNECTED1'),
            const Text("Sick App"),
        actions: <Widget>[
          FlatButton(
            textColor: conColor1,
            onPressed: () {
           //   connect();
            },
            child: const Text("Connected1"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
          FlatButton(
            textColor: conColor2,
            onPressed: () {
             // disconnect();
            },
            child: const Text("Connected2"),
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
                        "Front",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Material(
                      child: InkWell(
                        onTap: () {
                          // _stop();
                       //   advancedPlayer.stop();
                        },
                        onDoubleTap: (() {
                          _handleDoubleTap(1, DateTime.now());
                        }),
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
                        "Rear",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Material(
                      child: InkWell(
                        onTap: () {
                         // advancedPlayer.stop();
                        },
                        onDoubleTap: (() {
                          _handleDoubleTap(2, DateTime.now());
                        }),
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
                    //  ddValue = newValue;
                    if (!locked)
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
                         if (!locked)
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
                         if (!locked)
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
                // _stop();
                if (!locked)
                advancedPlayer.stop();
              },
            ),
            RaisedButton(
              child: Text('change Program Names'),
              onPressed: () {
                 if (!locked)
                _changeProgramNames();
              },
            ),
          ],
        ),
      ),
    );
  }

  void connectSensor1() {
    Socket.connect("192.168.0.10", 2112, timeout: tenSec).then((Socket sock1) {
      socket1 = sock1;
      socket1.listen(dataHandler1,
          onError: errorHandler1, onDone: doneHandler1, cancelOnError: true);
    }).whenComplete(() {
      print("copmleted trying to connect to sensor1.");
      if (socket1 == null) {
        print("socket1 is null");
        reconnect1 = true;
        watchdog1 = 0;
        //  if (timerProg1 != null) timerProg1.cancel();
      } else
        print("socket1 is connected");
      if (timerProg1 != null) timerProg1.cancel();
      timerProg1 = Timer.periodic(oneSec, (timerProg1) {
        sendData1();
      });
    }).timeout(Duration(seconds: 10), onTimeout: () {
      // method to handle a timeout exception and tell to view layer that
      // network operation fails
      // if we do not implement onTimeout callback the framework will throw a  TimeoutException

      print(
          "Can't connect to Sensor 1, either WIFI is off or the sensor is off, or they are not on the network");
      //  reconnect1 = true;
      //  watchdog1 = 0;
      //  if (timerProg1 != null) timerProg1.cancel();
    });
  }

  void connectSensor2() {
    Socket.connect("192.168.0.11", 2112, timeout: tenSec).then((Socket sock2) {
      socket2 = sock2;
      socket2.listen(dataHandler2,
          onError: errorHandler2, onDone: doneHandler2, cancelOnError: true);
    }).whenComplete(() {
      print("copmleted trying to connect to sensor2.");
      if (socket2 == null) {
        print("socket2 is null");
        reconnect2 = true;
        watchdog2 = 0;
        // if (timerProg2 != null) timerProg2.cancel();
      } else
        print("socket2 is connected");
      if (timerProg2 != null) timerProg2.cancel();
      timerProg2 = Timer.periodic(oneSec, (timerProg2) {
        sendData2();
      });
    }).timeout(Duration(seconds: 10), onTimeout: () {
      // method to handle a timeout exception and tell to view layer that
      // network operation fails
      // if we do not implement onTimeout callback the framework will throw a  TimeoutException

      print(
          "Can't connect to Sensor 2, either WIFI is off or the sensor is off, or they are not on the network");
      // reconnect2 = true;
      // if (timerProg2 != null) timerProg2.cancel();
      // watchdog2 = 0;
    });
  }

  // Socket connection
  void connect() {
    // Socket.startConnect(host, port)
    connectSensor1();
    connectSensor2();
    // if ((socket1 != null) && (socket2 != null)) {
    // print("connecting");
    timerProg = Timer.periodic(oneSec, (timerProg) {
      //sendDataTime();
    });

    //  }
    //else {
    //   setState(() {
    //    data1 = "error communicating with sensors!";
    //   });
    // }
  }

  static void sendData1() {
    try {
      String message = String.fromCharCode(2) +
          "sRN LIDoutputstate" +
          String.fromCharCode(3);
      if (socket1 != null) socket1.write(message);
      watchdog1 += 1;
      eternalWD1 += 1;
    } catch (e) {
      print("error sensor1 timer =>" + e.toString());
    }
  }

  static void sendData2() {
    try {
      String message = String.fromCharCode(2) +
          "sRN LIDoutputstate" +
          String.fromCharCode(3);
      if (socket2 != null) socket2.write(message);
      watchdog2 += 1;
      eternalWD2 += 1;
    } catch (e) {
      print("error sensor2 timer =>" + e.toString());
    }
  }

  void disconnect() {
    // socket1.destroy();
    // socket2.destroy();
    connected1 = false;
    connected2 = false;
    timerProg.cancel();
    timerProg1.cancel();
    timerProg2.cancel();
    // timerProg = null;
    // timerProg2 = null;
    while (timerProg.isActive) {}
    while (timerProg2.isActive) {}
    socket1.close();
    socket2.close();
    //  socket1 = null;
    //  socket2 = null;
    conColor1 = Colors.white;
    conColor2 = Colors.white;
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
          eternalWD1 = 1;
          connected1 = true;
          disTrig1 = false;
          conColor1 = Colors.green;
          //    print("new OUTPUT1 received");
          print("Time1: ${DateTime.now()} Data1: $data1");
          List<String> lastreceived1 = data1.split(" ");
          int count = 0;
          for (var i = 0; i < 20; i = i + 2) {
            blackOutputState[count] = int.parse(lastreceived1[i + 4]);
            count++;
          }
          // int prog = int.parse((dropdownValue.split(" "))[1]);
          int prog = (progNames.indexOf(ddValue)) + 1;
          if (blackOutputState[prog - 1] == 1)
          //al is ok. prog number equals program selected
          {
            alarm1 = false;
            //  print("OK1");
            if (_imageBlack != _imageBlackOk) {
              changePicBlack(_imageBlackOk);
              // _stop();
              if (!alarm1 && !alarm2) advancedPlayer.stop();
            }
          } else {
            print("ALARM1");
            alarm1 = true;
            //trigger alarm and change image!
            if (_imageBlack != _imageBlackAlarm) {
              changePicBlack(_imageBlackAlarm);
              //  if (!_isPlaying) {
              //     _isPlaying = true;
              // _play('sounds/alarm2.mp3');
              audioCache.loop('sounds/alarm.mp3');
              //    }
            }
          }
        }
      }
    });
  }

  void errorHandler1(error, StackTrace trace) {
    setState(() {
      data1 = "Error communiacting Sensor1";
      connected1 = false;
      print("error connecting to sensor 1");
      print(error);
      conColor1 = Colors.white;
      //  timerProg1.cancel();
    });
  }

  void doneHandler1() {
    setState(() {
      _imageBlack = _imageBlackDisconnect;
      data1 = "Closed communiaction Sensor1";
      connected1 = false;
      print("done handler1");
      socket1.destroy();
      conColor1 = Colors.white;
      timerProg1.cancel();
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
          eternalWD2 = 1;
          connected2 = true;
          disTrig2 = false;
          conColor2 = Colors.green;
          // print("new OUTPUT2 received");

          print("Time2: ${DateTime.now()} Data2: $data2");
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
          // int prog = int.parse((dropdownValue.split(" "))[1]);
          int prog = (progNames.indexOf(ddValue)) + 1;
          prog *= 2;
          currentMode == ModeOfOperation.one ? prog -= 1 : prog -= 0;
          //  print(prog);
          if (whiteOutputState[prog - 1] == 1)
          //al is ok. prog number equals program selected
          {
            //  print("OK2");
            if (_imageWhite != _imageWhiteOk) {
              //  _stop();
              alarm2 = false;
              if (!alarm1 && !alarm2) advancedPlayer.stop();
              changePicWhite(_imageWhiteOk);
            }
          } else {
            print("ALARM2");
            alarm2 = true;
            //trigger alarm and change image!
            if (_imageWhite != _imageWhiteAlarm) {
              //   if (!_isPlaying) {
              //    _isPlaying = true;
              // _play('sounds/alarm2.mp3');
              audioCache.loop('sounds/alarm.mp3');
              //   }
              changePicWhite(_imageWhiteAlarm);
            }
          }
        }
      }
    });
  }

  void errorHandler2(error, StackTrace trace) {
    setState(() {
      connected2 = false;
      data2 = "Error communiacting Sensor2";
      print(error);
      print("error connecting to sensor 2");
      conColor2 = Colors.white;
      //  timerProg2.cancel();
    });
  }

  void doneHandler2() {
    setState(() {
      _imageWhite = _imageWhiteDisconnect;
      data2 = "Closed communiaction Sensor2";
      connected2 = false;
      socket2.destroy();
      print("done handler2");
      conColor2 = Colors.white;
      timerProg2.cancel();
    });
  }

  void sendDataTime() {
    String message =
        String.fromCharCode(2) + "sRN STlms" + String.fromCharCode(3);
    socket1.write(message);
    socket2.write(message);
  }

  void watchDogTester() {
    if (watchdog1 > 2) {
      print("LIDAR1 disconnected! time off = $watchdog1");
      connected1 = false;
      conColor1 = Colors.white;
      // _imageBlack = _imageBlackDisconnect;

      if (_imageBlack != _imageBlackDisconnect) {
        changePicBlack(_imageBlackDisconnect);
      }

      if (!disTrig1) {
        audioCache.loop('sounds/siren.mp3');
        disTrig1 = true;
      }
      if ((watchdog1 > 20)) {
        watchdog1 = 0;
        print("trying reconnecting to Sensor1...");
        reconnect1 = false;
        connectSensor1();
      }
    }

    if (eternalWD1 > 2) {
      print("LIDAR1 eternalWD = $eternalWD1");
    }
    if (watchdog2 > 2) {
      print("LIDAR2 disconnected! time off = $watchdog2");
      connected2 = false;
      conColor2 = Colors.white;
      if (_imageWhite != _imageWhiteDisconnect) {
        changePicWhite(_imageWhiteDisconnect);
      }
      if (!disTrig2) {
        audioCache.loop('sounds/siren.mp3');
        disTrig2 = true;
      }
      if ((watchdog2 > 20)) {
        watchdog2 = 0;
        print("trying reconnecting to Sensor2...");
        reconnect2 = false;
        connectSensor2();
      }
    }

    if (eternalWD2 > 2) {
      print("LIDAR2 eternalWD = $eternalWD2");
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
                    //  dropdownValue = dropDown;
                    ddValue = dropDown;
                    print("the new Drop Down value is $ddValue");
                    //now reset the full area
                    currentMode = ModeOfOperation.one;
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
                      storage.writeNames(progNames);
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


  void _lockWasDetected(HardwareButtons.LockButtonEvent ev) {
    lockDetected = !lockDetected;
    //  if (lockDetected)
    {
      audioCache.loop('sounds/sleepMode.mp3');
    }
  }

  void _handleDoubleTap(int id, DateTime dt) {
    // id==1? oneisDouble = true: oneisDouble= false;
    //  id==2? twoisDouble = true: twoisDouble= false;
    if (id == 1) {
      dtOne = DateTime.now();
    }
    if (id == 2) {
      dtTwo = DateTime.now();
    }

    Duration difference = dtOne.difference(dtTwo);
    difference = difference.abs();
    print(difference);
    if (difference.compareTo(halfSec) < 0) {
      locked ? Screen.setBrightness(1) : Screen.setBrightness(0.2);
      locked = !locked;
    }
  }
}
