import 'dart:async';
import 'package:civideoconnectadmin/data_models/Doctors.dart';
import 'package:civideoconnectadmin/src/pages/DoctorSlotBlock.dart';
import 'package:civideoconnectadmin/src/pages/DoctorSlotSession.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:civideoconnectadmin/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:civideoconnectadmin/utils/Database.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:civideoconnectadmin/data_models/Specialization.dart';
import 'package:flutter/gestures.dart';

class DoctorSlot extends StatefulWidget {
  final String doctorCode;
  final String doctorName;
  const DoctorSlot({Key key, this.doctorCode, this.doctorName})
      : super(key: key);
  @override
  _DoctorSlotState createState() => _DoctorSlotState();
}

class _DoctorSlotState extends State<DoctorSlot> {
  int _current = 0;
  int doctorCharges = 0;
  var isLoading = false;
  bool isCommonSession = false;
  int entryType = 0;
  List<DoctorSessions> docSessions = [];
  List<DoctorNonWorkingDays> docNonWorking = [];
  List<String> dayText = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
  // List<bool> dayToShow = [false, false, false, false, false, false, false];
  List<bool> daySelected = [false, false, false, false, false, false, false];
  var docSessionList;
  var sessionCol;
  var nonworkingCol;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDoctorSession();
    getNonWorkingSession();
  }

  getDoctorSession() async {
    await DatabaseMethods()
        .getDoctorSessionsMaster(widget.doctorCode)
        .then((val) {
      setState(() {
        docSessions = val;
        getSessionDays();
      });
    });
  }

  getNonWorkingSession() async {
    await DatabaseMethods()
        .getDoctorNonWorkingMaster(widget.doctorCode)
        .then((val) {
      setState(() {
        docNonWorking = val;
        getSessionNonWorking();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle linkStyle = TextStyle(color: Colors.blue, fontSize: 15.0);
    TextStyle linkStyleSelected = TextStyle(
        color: Colors.blue, fontSize: 20.0, fontWeight: FontWeight.bold);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,

          elevation: 20.0,
          title: Text("Availability"),
          // title:  Text("Doctors", style: Theme.of(context).textTheme.title),
          actions: <Widget>[
            //
          ],
        ),
        body: SingleChildScrollView(
            child: Container(
          padding: const EdgeInsets.only(
              top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RichText(
                        text: TextSpan(
                            text: 'Sessions',
                            style:
                                entryType == 0 ? linkStyleSelected : linkStyle,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  entryType = 0;
                                });
                                //getDoctorSession();
                              })),
                    RichText(
                        text: TextSpan(
                            text: 'Add Non-working Timings',
                            style:
                                entryType == 1 ? linkStyleSelected : linkStyle,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  entryType = 1;
                                  //getNonWorkingSession();
                                });
                              }))
                  ],
                ),
              ),
              SizedBox(height: 20),
              //getSessionDays(),
              entryType == 0
                  ? sessionCol == null ? SizedBox() : sessionCol
                  : nonworkingCol == null ? SizedBox() : nonworkingCol
            ],
          ),
        )),
      ),
    );
  }

  getSessionDays() {
    TextStyle linkStyle = TextStyle(color: Colors.blue);

    List<Widget> days = [];
    for (int i = 0; i < dayText.length; i++) {
      List<Widget> sessions = [];
      List<DoctorSessions> _list = [];

      _list = docSessions.where((e) => e.sessionDay == dayText[i]).toList();

      for (int j = 0; j < _list.length; j++) {
        var mySessions = Container(
          //color: Colors.red,
          width: MediaQuery.of(context).size.width - 100,
          padding: const EdgeInsets.all(5.0),
          decoration: myBoxDecoration(),
          child: Column(
            children: <Widget>[
              Container(
                //color: Colors.blueAccent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '${_list[j].sessionTiming} Session',
                            ),
                            Text('(${_list[j].slotDuration} min)')
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          '${_list[j].startTime} - ${_list[j].endTime}',
                        ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        deleteDoctorSession(
                            widget.doctorCode, _list[j].sessionID);
                      },
                      child: Container(
                          child: Icon(Icons.delete, color: Colors.red)),
                    )
                  ],
                ),
              ),
            ],
          ),
        );

        sessions.add(mySessions);
      }
      sessions.add(Container(
        width: MediaQuery.of(context).size.width - 100,
        padding: const EdgeInsets.all(5.0),
        decoration: myBoxDecoration(),
        child: RichText(
            text: TextSpan(
                text: 'Add Session',
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    addDoctorSession(i);
                  })),
      ));

      var myRow = Container(
          padding: const EdgeInsets.all(5.0),
          decoration: myBoxDecoration(),
          child: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(width: 40, child: Text(dayText[i])),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sessions,
                ),
              ],
            ),
          ));

      days.add(myRow);
      // days.add(new SizedBox(
      //   height: 20,
      // ));
    }

    var myCols = Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, children: days));

    sessionCol = myCols;
  }

  getSessionNonWorking() {
    TextStyle linkStyle = TextStyle(color: Colors.blue);
    List<Widget> sessions = [];
    sessions.add(Container(
      width: MediaQuery.of(context).size.width - 100,
      padding: const EdgeInsets.all(5.0),
      decoration: myBoxDecoration(),
      child: RichText(
          text: TextSpan(
              text: 'Add',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  addNonWorkingSession();
                })),
    ));
    for (int i = 0; i < docNonWorking.length; i++) {
      var mySessions = Container(
        //color: Colors.red,
        width: MediaQuery.of(context).size.width - 100,
        padding: const EdgeInsets.all(5.0),
        decoration: myBoxDecoration(),
        child: Column(
          children: <Widget>[
            Container(
              //color: Colors.blueAccent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '${docNonWorking[i].fromDate} - ${docNonWorking[i].toDate}',
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        '${docNonWorking[i].remark}',
                      ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // deleteNonWorkingSession(
                      //     widget.doctorCode, docNonWorking[i].id);
                    },
                    child:
                        Container(child: Icon(Icons.delete, color: Colors.red)),
                  )
                ],
              ),
            ),
          ],
        ),
      );

      sessions.add(mySessions);
    }

    var myCols = Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: sessions));

    nonworkingCol = myCols;
  }

  addDoctorSession(int i) async {
    // globals.dayToShow = [false, false, false, false, false, false, false];
    // globals.dayToShow[i] = true;

    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorSlotSession(
              doctorCode: widget.doctorCode,
              doctorName: widget.doctorName,
              sessionDay: i),
        ));
    getDoctorSession();
  }

  addNonWorkingSession() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DoctorSlotBlock(
                  doctorCode: widget.doctorCode,
                  doctorName: widget.doctorName,
                )));
    getDoctorSession();
  }

  deleteDoctorSession(doctorCode, sessionID) {
    DatabaseMethods().deleteDoctorSession(doctorCode, sessionID);

    setState(() {
      docSessions.removeWhere((element) => element.sessionID == sessionID);
      getSessionDays();
    });
  }

  deleteNonWorkingSession(doctorCode, id) {
    DatabaseMethods().deleteNonWorkingSession(doctorCode, id);

    setState(() {
      docNonWorking.removeWhere((element) => element.id == id);
      getSessionNonWorking();
    });
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
        border: Border.all(
      color: Colors.grey[400],
    ));
  }
}
