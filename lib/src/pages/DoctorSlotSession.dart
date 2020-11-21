import 'dart:async';
import 'package:civideoconnectadmin/data_models/Doctors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:civideoconnectadmin/globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:civideoconnectadmin/utils/Database.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:civideoconnectadmin/data_models/Specialization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';

class DoctorSlotSession extends StatefulWidget {
  final String doctorCode;
  final String doctorName;
  final int sessionDay;
  const DoctorSlotSession(
      {Key key, this.doctorCode, this.doctorName, this.sessionDay})
      : super(key: key);

  @override
  _DoctorSlotSessionState createState() => _DoctorSlotSessionState();
}

class _DoctorSlotSessionState extends State<DoctorSlotSession> {
  int _current = 0;

  var isLoading = false;
  bool isCommonSession = false;
  int sessionTimingID = -1;
  int sessionTypeID;
  int slotDuration = 15;
  TimeOfDay startTimeTOD;
  TimeOfDay endTimeTOD;
  int doctorCharges = 0;
  bool showTimeSelection = false;
  bool showDurationSelection = false;
  List<Widget> daysWidget = [];
  List<String> dayText = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
  List<bool> daySelected = [false, false, false, false, false, false, false];
  List<DoctorSessions> docSessions = [];
  //List<bool> dayToShow = [true, true, true, true, true, true, true];
  Color accentColor;
  final TextEditingController chargesController = new TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    globals.dayToShow = [false, false, false, false, false, false, false];
    globals.dayToShow[widget.sessionDay] = true;
  }

  // getDoctorSessions() async {
  //   await DatabaseMethods()
  //       .getDoctorSessionsForDay(widget.doctorCode, widget.sessionDay)
  //       .then((value) => docSessions = value);

  //   if (docSessions.length > 0) {

  //   }
  // }

  setDaysWidget() {
    for (var i = 0; i < 7; i++) {
      if (globals.dayToShow[i] == true) daySelected[i] = true;
    }

    for (int i = 0; i < dayText.length; i++) {
      daysWidget.add(new Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          dayText[i],
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    accentColor = Theme.of(context).accentColor;
    if (daysWidget.length == 0) setDaysWidget();
    TextStyle linkStyle = TextStyle(color: Colors.blue);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,

          elevation: 20.0,
          title: Text("Add Session"),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Days"),
              SizedBox(
                height: 20,
              ),
              ToggleButtons(
                borderColor: Colors.grey[200],
                fillColor: accentColor,
                borderWidth: 2,
                selectedBorderColor: Colors.grey[200],
                selectedColor: Colors.white,
                borderRadius: BorderRadius.circular(0),
                children: daysWidget,
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < daySelected.length; i++) {
                      if (i == index) {
                        //if (globals.dayToShow[i] == true) {
                        if (daySelected[i] == true) {
                          daySelected[i] = false;
                        } else
                          daySelected[i] = true;
                        // } else {
                        //   daySelected[i] = false;
                        // }
                      }
                    }
                  });
                },
                isSelected: daySelected,
              ),
              SizedBox(
                height: 20,
              ),
              Text("Session Type"),
              Row(
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Radio(
                        value: 0,
                        groupValue: sessionTypeID,
                        onChanged: changesessionTypeID,
                      ),
                      new Text(
                        'Personal Visit',
                        style:
                            new TextStyle(fontSize: 16.0, color: accentColor),
                      ),
                      new Radio(
                        value: 1,
                        groupValue: sessionTypeID,
                        onChanged: changesessionTypeID,
                      ),
                      new Text(
                        'Video Consultation',
                        style:
                            new TextStyle(fontSize: 16.0, color: accentColor),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                  onTap: () {
                    setState(() {
                      _showConsultationChargesEntry(context);
                    });
                  },
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Consultation Charges"),
                        Row(
                          children: <Widget>[
                            Text(
                              "Rs. $doctorCharges",
                              style: TextStyle(color: accentColor),
                            ),
                            Icon(Icons.arrow_right)
                          ],
                        ),
                      ],
                    ),
                  )),
              SizedBox(
                height: 20,
              ),
              Text("Session Timing"),
              Row(
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Radio(
                        value: 0,
                        groupValue: sessionTimingID,
                        onChanged: changesessionTimingID,
                      ),
                      new Text(
                        'Morning',
                        style:
                            new TextStyle(fontSize: 16.0, color: accentColor),
                      ),
                      new Radio(
                        value: 1,
                        groupValue: sessionTimingID,
                        onChanged: changesessionTimingID,
                      ),
                      new Text(
                        'Afternoon',
                        style:
                            new TextStyle(fontSize: 16.0, color: accentColor),
                      ),
                      new Radio(
                        value: 2,
                        groupValue: sessionTimingID,
                        onChanged: changesessionTimingID,
                      ),
                      new Text(
                        'Evening',
                        style:
                            new TextStyle(fontSize: 16.0, color: accentColor),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                  onTap: () {
                    setState(() {
                      showTimeSelection = false;
                      showDurationSelection
                          ? showDurationSelection = false
                          : showDurationSelection = true;
                    });
                  },
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Slot Duration"),
                        Row(
                          children: <Widget>[
                            Text(
                              "$slotDuration minutes",
                              style: TextStyle(color: accentColor),
                            ),
                            Icon(Icons.arrow_right)
                          ],
                        ),
                      ],
                    ),
                  )),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (sessionTimingID >= 0) {
                      showDurationSelection = false;
                      showTimeSelection
                          ? showTimeSelection = false
                          : showTimeSelection = true;
                    }
                  });
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Session Time"),
                      Row(
                        children: <Widget>[
                          Text(
                            "${timeOfDayToString(startTimeTOD)} - ${timeOfDayToString(endTimeTOD)}",
                            style: TextStyle(color: accentColor),
                          ),
                          Icon(Icons.arrow_right)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  RawMaterialButton(
                    onPressed: () {
                      saveDoctorSession();
                    },
                    child: Text("Save"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(color: accentColor)),
                    elevation: 2.0,
                    //fillColor: Theme.of(context).accentColor,
                    padding: const EdgeInsets.all(5.0),
                  ),
                  SizedBox(width: 20),
                  RawMaterialButton(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                    child: Text("Cancel"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(color: accentColor)),
                    elevation: 2.0,
                    //fillColor: Theme.of(context).accentColor,
                    padding: const EdgeInsets.all(5.0),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  child: (showTimeSelection == true)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text("Start Time"),
                            Text("End Time")
                          ],
                        )
                      : (showDurationSelection == true)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text("Duration"),
                              ],
                            )
                          : SizedBox()),
              SizedBox(
                height: 20,
              ),
              Container(
                  height: 200,
                  child: (showTimeSelection == true)
                      ? getTimeSelection()
                      : (showDurationSelection == true)
                          ? getDurationSelection()
                          : SizedBox()),
            ],
          ),
        )),
      ),
    );
  }

  saveDoctorSession() async {
    String sessionID = "";
    String sessionTiming;
    int consultationFee;
    String startTime;
    String endTime;

    if (sessionTimingID == 0)
      sessionTiming = "Morning";
    else if (sessionTimingID == 1)
      sessionTiming = "Afternoon";
    else if (sessionTimingID == 2) sessionTiming = "Evening";

    consultationFee = doctorCharges;

    startTime = timeOfDayToString(startTimeTOD);
    endTime = timeOfDayToString(endTimeTOD);

    for (var i = 0; i < daySelected.length; i++) {
      if (daySelected[i] == true) {
        sessionID = dayText[i];
        Map<String, dynamic> doctorSession = {
          "doctorCode": widget.doctorCode,
          "sessionTiming": sessionTiming,
          "sessionTimingID": sessionTimingID,
          "sessionTypeID": sessionTypeID,
          "consultationFee": consultationFee,
          "startTime": startTime,
          "endTime": endTime,
          "slotDuration": slotDuration,
          "sessionDay": dayText[i],
          "sessionID": "${widget.doctorCode}_${dayText[i]}_$sessionTiming",
        };

        await DatabaseMethods().addDoctorSession(widget.doctorCode,
            doctorSession, "${widget.doctorCode}_${dayText[i]}_$sessionTiming");
      }
    }

    Navigator.pop(context);
  }

  getDurationSelection() {
    showTimeSelection = false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: DurationPicker(
            duration: new Duration(minutes: slotDuration),
            onChange: (val) {
              this.setState(() => slotDuration = val.inMinutes);
            },
            snapToMins: 5.0,
          ),
        ),
      ],
    );
  }

  getTimeSelection() {
    showDurationSelection = false;
    return Row(
      children: <Widget>[
        Flexible(
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            initialDateTime:
                DateTime(1969, 1, 1, startTimeTOD.hour, startTimeTOD.minute),
            onDateTimeChanged: (DateTime newDateTime) {
              var newTod = TimeOfDay.fromDateTime(newDateTime);
              // setState(() {
              //   selectedTime = "";
              // });

              _updateStartTime(newTod);
            },
            use24hFormat: false,
            minuteInterval: 1,
          ),
        ),
        Flexible(
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            initialDateTime:
                DateTime(1969, 1, 1, endTimeTOD.hour, endTimeTOD.minute),
            onDateTimeChanged: (DateTime newDateTime) {
              var newTod = TimeOfDay.fromDateTime(newDateTime);
              // setState(() {
              //   selectedTime = "";
              // });

              _updateEndTime(newTod);
            },
            use24hFormat: false,
            minuteInterval: 1,
          ),
        ),
      ],
    );
  }

  _updateStartTime(newTod) {
    setState(() {
      startTimeTOD = newTod;
    });
  }

  _updateEndTime(newTod) {
    setState(() {
      endTimeTOD = newTod;
    });
  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.jm(); //"6:00 AM"

    return TimeOfDay.fromDateTime(format.parse(tod));
  }

  String timeOfDayToString(TimeOfDay tod) {
    if (tod == null) return "NS";

    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  void changesessionTimingID(int value) {
    setState(() {
      showTimeSelection = false;
      sessionTimingID = value;
      if (sessionTimingID == 0) {
        startTimeTOD = stringToTimeOfDay("9:00 AM");
        endTimeTOD = stringToTimeOfDay("12:00 PM");
      } else if (sessionTimingID == 1) {
        startTimeTOD = stringToTimeOfDay("12:00 PM");
        endTimeTOD = stringToTimeOfDay("06:00 PM");
      } else if (sessionTimingID == 2) {
        startTimeTOD = stringToTimeOfDay("06:00 PM");
        endTimeTOD = stringToTimeOfDay("09:00 PM");
      }
    });
  }

  void changesessionTypeID(int value) {
    setState(() {
      sessionTypeID = value;
    });
  }

  _showConsultationChargesEntry(BuildContext context) async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 2 -
                        250 // adjust values according to your need
                    ), // adjust values according to your need
                child: AlertDialog(
                    title: Text("Consultation Charges"),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          controller: chargesController,
                          decoration: const InputDecoration(
                            icon: const Icon(Icons.image),
                            hintText: '',
                            labelText: 'Charges',
                          ),
                          keyboardType: TextInputType.number,
                        )
                      ],
                    ),
                    actions: <Widget>[
                      RawMaterialButton(
                        onPressed: () {
                          setState(() {
                            doctorCharges = int.parse(chargesController.text);
                          });

                          Navigator.pop(context);
                        },
                        child: Text("Save"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(color: accentColor)),
                        elevation: 2.0,
                        //fillColor: Theme.of(context).accentColor,
                        padding: const EdgeInsets.all(5.0),
                      ),
                      SizedBox(width: 20),
                      RawMaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(color: accentColor)),
                        elevation: 2.0,
                        //fillColor: Theme.of(context).accentColor,
                        padding: const EdgeInsets.all(5.0),
                      )
                    ]));
          });
        });
  }

  _showTimeSelection(BuildContext context) async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 2 -
                        250 // adjust values according to your need
                    ), // adjust values according to your need
                child: AlertDialog(
                    title: Text("Select Start Time and End Time"),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[],
                    ),
                    actions: <Widget>[
                      RawMaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Save"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(color: accentColor)),
                        elevation: 2.0,
                        //fillColor: Theme.of(context).accentColor,
                        padding: const EdgeInsets.all(5.0),
                      ),
                      SizedBox(width: 20),
                      RawMaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(color: accentColor)),
                        elevation: 2.0,
                        //fillColor: Theme.of(context).accentColor,
                        padding: const EdgeInsets.all(5.0),
                      )
                    ]));
          });
        });
  }
}
