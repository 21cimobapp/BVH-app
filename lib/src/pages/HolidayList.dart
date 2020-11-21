import 'dart:async';
import 'package:civideoconnectadmin/utils/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:civideoconnectadmin/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:civideoconnectadmin/utils/Database.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';

class HolidayList extends StatefulWidget {
  @override
  _HolidayListState createState() => _HolidayListState();
}

class _HolidayListState extends State<HolidayList> {
  List<HolidayData> holidayList = List<HolidayData>();
  final TextEditingController holidayDetails = new TextEditingController();
  DateTime selectedDate;
  var isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadHolidays();
  }

  loadHolidays() {
    DatabaseMethods().getHolidays().then((val) {
      setState(() {
        holidayList = val;
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
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Column(children: [
                  Container(
                      decoration: myBoxDecoration(),
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Add Holiday"),
                            Divider(
                              height: 10.0,
                              //indent: 5.0,
                              color: Colors.black87,
                            ),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showDateSelection();
                                  });
                                },
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Holiday Date"),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            selectedDate == null
                                                ? "Select date"
                                                : DateFormat(
                                                        'EEEE, dd MMM yyyy')
                                                    .format(selectedDate),
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                          Icon(Icons.arrow_right)
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                            Container(
                                child: TextFormField(
                                    controller: holidayDetails,
                                    decoration: const InputDecoration(
                                      hintText: '',
                                      labelText: 'Hoilday details',
                                    ))),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                RawMaterialButton(
                                  onPressed: () {
                                    saveHoliday();
                                  },
                                  child: Text("Save"),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      side: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  elevation: 2.0,
                                  //fillColor: Theme.of(context).accentColor,
                                  padding: const EdgeInsets.all(5.0),
                                ),
                              ],
                            )
                          ],
                        ),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Holiday List"),
                    ],
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: ListView.builder(
                          itemCount: holidayList.length,
                          itemBuilder: (BuildContext context, int i) =>
                              GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 5.0,
                                        bottom: 5.0,
                                        left: 10.0,
                                        right: 10.0),
                                    child: Card(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 5),
                                        elevation: 10.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: Column(children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0,
                                                bottom: 10.0,
                                                left: 10.0,
                                                right: 10.0),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Container(
                                                        width: 280,
                                                        child: Text(
                                                            DateFormat(
                                                                    'EEEE, dd MMM yyyy')
                                                                .format(holidayList[
                                                                        i]
                                                                    .holidayDate),
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .subtitle,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                      ),
                                                      Text(
                                                        holidayList[i]
                                                            .holidayDetails,
                                                        style: TextStyle(
                                                            color: Colors.grey),
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                    ],
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      deleteHoliday(
                                                          holidayList[i]
                                                              .holidayCode);
                                                    },
                                                    child: Container(
                                                        child: Icon(
                                                            Icons.delete,
                                                            color: Colors.red)),
                                                  )
                                                ]),
                                          ),
                                        ])),
                                  )))),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  deleteHoliday(holidayCode) async {
    await DatabaseMethods().deleteHoliday(holidayCode);

    setState(() {
      holidayList.removeWhere((element) => element.holidayCode == holidayCode);
    });
  }

  showDateSelection() async {
    DateTime startDate = DateTime.now();

    DateTime sDate = await showRoundedDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: startDate,
      lastDate: DateTime(DateTime.now().year + 1),
      borderRadius: 16,
    );

    setState(() {
      selectedDate = sDate;
    });
  }

  saveHoliday() async {
    String holidayCode = "";

    holidayCode = DateFormat('ddMMyyyy').format(selectedDate);
    Map<String, dynamic> holidayData = {
      "holidayCode": holidayCode,
      "holidayDate": selectedDate,
      "holidayDetails": holidayDetails.text,
    };
    await DatabaseMethods().addHoliday(holidayCode, holidayData);
    setState(() {
      holidayDetails.clear();
      selectedDate = null;
    });
    loadHolidays();
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(
          color: Colors.grey[400],
        ));
  }
}
