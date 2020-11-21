import 'dart:async';
import 'package:civideoconnectadmin/data_models/Doctors.dart';
import 'package:civideoconnectadmin/src/pages/DoctorCalendar.dart';
import 'package:civideoconnectadmin/src/pages/DoctorSlot.dart';
import 'package:civideoconnectadmin/utils/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:civideoconnectadmin/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:civideoconnectadmin/utils/Database.dart';

class DoctorList extends StatefulWidget {
  @override
  _DoctorListState createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {
  int _current = 0;

  var isLoading = false;
  Stream<QuerySnapshot> doctors;
  List<Doctors> _doctor = List<Doctors>();
  List<String> speciality = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    DatabaseMethods().getDoctorsMaster().then((val) {
      setState(() {
        doctors = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle linkStyle = TextStyle(color: Colors.blue);
    return SafeArea(
      child: Scaffold(
        //backgroundColor: Theme.of(context).primaryColor,

        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(
                top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Doctor List"),
                      Row(
                        children: <Widget>[
                          RawMaterialButton(
                            onPressed: () {
                              updateDefaultMasters();
                            },
                            child: Text("Default Masters"),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            elevation: 2.0,
                            //fillColor: Theme.of(context).accentColor,
                            padding: const EdgeInsets.all(5.0),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          RawMaterialButton(
                            onPressed: () {
                              updateDoctorListApex();
                            },
                            child: Text("Refresh"),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            elevation: 2.0,
                            //fillColor: Theme.of(context).accentColor,
                            padding: const EdgeInsets.all(5.0),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height - 140,
                      child: StreamBuilder(
                          stream: doctors,
                          builder: (context, snapshot) {
                            return snapshot.hasData
                                ? ListView.builder(
                                    itemCount: snapshot.data.documents.length,
                                    itemBuilder:
                                        (BuildContext context, int i) =>
                                            GestureDetector(
                                                onTap: () {},
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5.0,
                                                          bottom: 5.0,
                                                          left: 10.0,
                                                          right: 10.0),
                                                  child: Card(
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5),
                                                      elevation: 10.0,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                      child: Column(
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 10.0,
                                                                      bottom:
                                                                          10.0,
                                                                      left:
                                                                          10.0,
                                                                      right:
                                                                          10.0),
                                                              child: Row(
                                                                  children: <
                                                                      Widget>[
                                                                    MyCircleAvatar(
                                                                        imgUrl:
                                                                            "",
                                                                        personType:
                                                                            "DOCTOR",
                                                                        size:
                                                                            50),
                                                                    SizedBox(
                                                                        width:
                                                                            20),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: <
                                                                          Widget>[
                                                                        Container(
                                                                          width:
                                                                              270,
                                                                          child: Text(
                                                                              snapshot.data.documents[i].data["doctorName"],
                                                                              style: Theme.of(context).textTheme.subtitle,
                                                                              overflow: TextOverflow.ellipsis),
                                                                        ),
                                                                        Text(
                                                                          snapshot
                                                                              .data
                                                                              .documents[i]
                                                                              .data["qualification"],
                                                                          style:
                                                                              TextStyle(color: Colors.grey),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          snapshot
                                                                              .data
                                                                              .documents[i]
                                                                              .data["specialityCode"],
                                                                          style:
                                                                              TextStyle(color: Colors.grey),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ]),
                                                            ),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 5.0,
                                                                      bottom:
                                                                          5.0,
                                                                      left: 5.0,
                                                                      right:
                                                                          5.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: <
                                                                    Widget>[
                                                                  // RawMaterialButton(
                                                                  //   onPressed:
                                                                  //       () {
                                                                  //     Navigator.push(
                                                                  //         context,
                                                                  //         MaterialPageRoute(
                                                                  //           builder: (context) =>
                                                                  //               DoctorCalendar(),
                                                                  //         ));
                                                                  //   },
                                                                  //   child: Text(
                                                                  //       "Calendar"),
                                                                  //   shape: RoundedRectangleBorder(
                                                                  //       borderRadius:
                                                                  //           BorderRadius.circular(
                                                                  //               25.0),
                                                                  //       side: BorderSide(
                                                                  //           color:
                                                                  //               Theme.of(context).primaryColor)),
                                                                  //   elevation:
                                                                  //       2.0,
                                                                  //   //fillColor: Theme.of(context).accentColor,
                                                                  //   padding:
                                                                  //       const EdgeInsets.all(
                                                                  //           5.0),
                                                                  // ),
                                                                  // SizedBox(
                                                                  //   width: 20,
                                                                  // ),
                                                                  RawMaterialButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                DoctorSlot(doctorCode: snapshot.data.documents[i].data["doctorCode"], doctorName: snapshot.data.documents[i].data["doctorName"]),
                                                                          ));
                                                                    },
                                                                    child: Text(
                                                                        "Availability"),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                25.0),
                                                                        side: BorderSide(
                                                                            color:
                                                                                Theme.of(context).primaryColor)),
                                                                    elevation:
                                                                        2.0,
                                                                    //fillColor: Theme.of(context).accentColor,
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            5.0),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ])),
                                                )))
                                : Container(child: Text("Loading..."));
                          }))
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  updateDoctorListApex() async {
    await apiData("ALL").then((value) {
      _doctor.addAll(value);
    });
    int specialitySeq = 0;

    for (int i = 0; i < _doctor.length - 1; i++) {
      Map<String, dynamic> doctorData = {
        "doctorCode": _doctor[i].DoctorCode,
        "doctorName": _doctor[i].DoctorName,
        "designation": _doctor[i].Designation,
        "qualification": _doctor[i].Qualification,
        "specialityCode": _doctor[i].SpecialityCode,
      };

      if (speciality.contains("${_doctor[i].SpecialityCode}") == false) {
        speciality.add("${_doctor[i].SpecialityCode}");

        specialitySeq = specialitySeq + 1;
        Map<String, dynamic> specializationData = {
          "specialityCode": _doctor[i].SpecialityCode,
          "speciality": _doctor[i].Speciality,
          "description": "",
          "sequence": specialitySeq,
        };
        DatabaseMethods()
            .addSpeciality(_doctor[i].SpecialityCode, specializationData);
      }
      DatabaseMethods().addDoctors(_doctor[i].DoctorCode, doctorData);
    }
  }

  updateDefaultMasters() async {
    List<String> dayText = ["MON", "TUE", "WED", "THU", "FRI", "SAT"];

    List<DoctorData> _doctor = List<DoctorData>();

    await DatabaseMethods()
        .getDoctors("ALL")
        .then((value) => {_doctor = value});

    for (int i = 0; i < _doctor.length; i++) {
      for (int iday = 0; iday < dayText.length; iday++) {
        Map<String, dynamic> doctorSession = {
          "doctorCode": _doctor[i].doctorCode,
          "sessionTiming": "Morning",
          "sessionTimingID": 0,
          "sessionTypeID": 1,
          "consultationFee": 500,
          "startTime": "9:00 AM",
          "endTime": "12:00 PM",
          "slotDuration": 15,
          "sessionDay": dayText[iday],
          "sessionID": "${_doctor[i].doctorCode}_${dayText[iday]}_Morning",
        };
        await DatabaseMethods().addDoctorSession(_doctor[i].doctorCode,
            doctorSession, "${_doctor[i].doctorCode}_${dayText[iday]}_Morning");
      }
    }
  }

  Future<List<Doctors>> apiData(spec) async {
    var url = "${globals.apiHostingURL}/Patient/mapp_GetSpecialityWiseDoctors";
    var response = await http
        .post(url, body: {"SpecialityCode": spec, "OrganizationCode": "H05"});

    var doc = List<Doctors>();
    if (response.statusCode == 200) {
      var patientJson = json.decode(response.body)['specialityWiseDoctors'];
      if (patientJson != null) {
        for (var notejson in patientJson) {
          doc.add(Doctors.fromJson(notejson));
        }
      }
    }
    return doc;
    //var extractdata = jsonDecode(response.body);
    //print(extractdata);
  }
}
