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

class DoctorSlotBlock extends StatefulWidget {
  final String doctorCode;
  final String doctorName;

  const DoctorSlotBlock({Key key, this.doctorCode, this.doctorName})
      : super(key: key);

  @override
  _DoctorSlotBlockState createState() => _DoctorSlotBlockState();
}

class _DoctorSlotBlockState extends State<DoctorSlotBlock> {
  int _current = 0;

  var isLoading = false;
  bool isCommonSession = false;
  int sessionTimingID;
  int sessionTypeID;
  int slotDuration = 15;
  DateTime startDateTime;
  DateTime endDateTime;
  int doctorCharges = 0;
  bool showTimeSelection = false;
  bool showDurationSelection = false;
  bool isAllDay = true;
  //List<bool> dayToShow = [true, true, true, true, true, true, true];

  final TextEditingController chargesController = new TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle linkStyle = TextStyle(color: Colors.blue);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,

          elevation: 20.0,
          title: Text("Non-Working Timing"),
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
              SizedBox(
                height: 10,
              ),
              // Row(
              //   children: <Widget>[
              //     Switch(
              //       value: isAllDay,
              //       onChanged: (value) {
              //         setState(() {
              //           isAllDay = value;
              //         });
              //         //getAppointments1(_selectedValue);
              //       },
              //       activeTrackColor: Colors.grey[200],
              //       activeColor: Theme.of(context).accentColor,
              //     ),
              //     Text(
              //       "All Day",
              //       style: TextStyle(fontSize: 15),
              //     )
              //   ],
              // ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showTimeSelection
                        ? showTimeSelection = false
                        : showTimeSelection = true;
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
                            startDateTime == null
                                ? "Select Date"
                                : "${startDateTime} - ${endDateTime}",
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          ),
                          //Icon(Icons.arrow_right)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),

              // Container(
              //     child: Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: <Widget>[Text("Start Date"), Text("End Date")],
              // )),
              // SizedBox(
              //   height: 20,
              // ),
              Container(height: 300, child: getTimeSelection()),
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
                        side:
                            BorderSide(color: Theme.of(context).primaryColor)),
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
                        side:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    elevation: 2.0,
                    //fillColor: Theme.of(context).accentColor,
                    padding: const EdgeInsets.all(5.0),
                  )
                ],
              ),
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

    // startTime = timeOfDayToString(startTimeTOD);
    // endTime = timeOfDayToString(endTimeTOD);

    // for (var i = 0; i < daySelected.length; i++) {
    //   if (daySelected[i] == true) {
    //     sessionID = dayText[i];
    //     Map<String, dynamic> doctorSession = {
    //       "doctorCode": widget.doctorCode,
    //       "sessionTiming": sessionTiming,
    //       "sessionTimingID": sessionTimingID,
    //       "sessionTypeID": sessionTypeID,
    //       "consultationFee": consultationFee,
    //       "startTime": startTime,
    //       "endTime": endTime,
    //       "slotDuration": slotDuration,
    //       "sessionDay": dayText[i],
    //       "sessionID": "${widget.doctorCode}_${dayText[i]}_$sessionTiming",
    //     };

    //     await DatabaseMethods().addDoctorSession(widget.doctorCode,
    //         doctorSession, "${widget.doctorCode}_${dayText[i]}_$sessionTiming");
    //   }
    // }

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
    return Column(
      children: <Widget>[
        Text("Start Date"),
        SizedBox(
          height: 20,
        ),
        Flexible(
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            minimumDate: DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day),
            maximumDate: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day)
                .add(Duration(days: 7)),
            initialDateTime: DateTime.now(),
            onDateTimeChanged: (DateTime newDateTime) {
              //var newTod = TimeOfDay.fromDateTime(newDateTime);
              // setState(() {
              //   selectedTime = "";
              // });

              _updateStartTime(newDateTime);
            },
            //use24hFormat: false,
            //minuteInterval: 1,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Text("End Date"),
        SizedBox(
          height: 20,
        ),
        Flexible(
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: startDateTime == null
                ? DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day)
                : startDateTime,
            minimumDate: startDateTime == null
                ? DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day)
                : startDateTime,
            maximumDate: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day)
                .add(Duration(days: 7)),
            onDateTimeChanged: (DateTime newDateTime) {
              //var newTod = TimeOfDay.fromDateTime(newDateTime);
              // setState(() {
              //   selectedTime = "";
              // });

              _updateEndTime(newDateTime);
            },
            use24hFormat: false,
            minuteInterval: 1,
          ),
        ),
      ],
    );
  }

  _updateStartTime(newDateTime) {
    setState(() {
      startDateTime = newDateTime;
    });
  }

  _updateEndTime(newDateTime) {
    setState(() {
      endDateTime = newDateTime;
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

  // void changesessionTimingID(int value) {
  //   setState(() {
  //     showTimeSelection = false;
  //     sessionTimingID = value;
  //     if (sessionTimingID == 0) {
  //       startTimeTOD = stringToTimeOfDay("9:00 AM");
  //       endTimeTOD = stringToTimeOfDay("12:00 PM");
  //     } else if (sessionTimingID == 1) {
  //       startTimeTOD = stringToTimeOfDay("12:00 PM");
  //       endTimeTOD = stringToTimeOfDay("06:00 PM");
  //     } else if (sessionTimingID == 2) {
  //       startTimeTOD = stringToTimeOfDay("06:00 PM");
  //       endTimeTOD = stringToTimeOfDay("09:00 PM");
  //     }
  //   });
  // }

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
                            side: BorderSide(
                                color: Theme.of(context).primaryColor)),
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
                            side: BorderSide(
                                color: Theme.of(context).primaryColor)),
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
                    title: Text("Select Start Date and End Date"),
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
                            side: BorderSide(
                                color: Theme.of(context).primaryColor)),
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
                            side: BorderSide(
                                color: Theme.of(context).primaryColor)),
                        elevation: 2.0,
                        //fillColor: Theme.of(context).accentColor,
                        padding: const EdgeInsets.all(5.0),
                      )
                    ]));
          });
        });
  }
}
