import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'package:civideoconnectadmin/src/pages/UploadFile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:civideoconnectadmin/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:civideoconnectadmin/utils/Database.dart';
import 'package:carousel_slider/carousel_slider.dart';

//import 'package:civideoconnectapp/firebase/auth/phone_auth/authservice.dart';

class HomePageAdmin extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePageAdmin> {
  int _current = 0;
  List<SliderImages> sliderImages = [];
  var isLoading = false;

  // List<String> imgList = [
  //   'https://firebasestorage.googleapis.com/v0/b/civideoconnectapp.appspot.com/o/SliderImages%2Fdoctor%2F4ed6617a-f5f2-4ac5-ab61-0e0148492a6c.?alt=media&token=b93b472a-f202-4409-8924-bfd5ebc20e69',
  //   'https://images.unsplash.com/photo-1578496480240-32d3e0c04525?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1950&q=80',
  //   'https://images.pexels.com/photos/127873/pexels-photo-127873.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
  //   'https://images.pexels.com/photos/139398/thermometer-headache-pain-pills-139398.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
  //   'https://images.pexels.com/photos/4386513/pexels-photo-4386513.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
  // ];

  List<String> imgList = [];
  List<String> imgListTitle = [];

  List<String> imgListDoctor = [];
  List<String> imgListDoctorTitle = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadSliderImages();
  }

  loadSliderImages() async {
    sliderImages = [];

    await DatabaseMethods().getSliderImages("doctor").then((val) {
      sliderImages = val;
    });
    imgListDoctor.clear();
    imgListDoctorTitle.clear();
    imgList.clear();
    imgListTitle.clear();

    if (sliderImages.length > 0) {
      for (int i = 0; i < sliderImages.length; i++) {
        imgListDoctor.add(sliderImages[i].documentURL);
        imgListDoctorTitle.add(sliderImages[i].documentTitle);
      }
    }

    sliderImages = [];

    await DatabaseMethods().getSliderImages("patient").then((val) {
      sliderImages = val;
    });

    if (sliderImages.length > 0) {
      for (int i = 0; i < sliderImages.length; i++) {
        imgList.add(sliderImages[i].documentURL);
        imgListTitle.add(sliderImages[i].documentTitle);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> imageSliders = imgList
        .map((item) => Container(
              child: Container(
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        Image.network(item,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width - 50),
                        Positioned(
                          top: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                RawMaterialButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UploadFile(
                                            userType: "patient",
                                            imageID:
                                                imgListDoctor.indexOf(item),
                                          ),
                                        ));
                                  },
                                  child: Text("Change"),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      side: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  elevation: 2.0,
                                  fillColor: Colors.blueGrey,
                                  padding: const EdgeInsets.all(5.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${imgList.indexOf(item) + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${imgListTitle[imgList.indexOf(item)]}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ))
        .toList();

    final List<Widget> imageSlidersDoctor = imgListDoctor
        .map((item) => Container(
              child: Container(
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        Image.network(item,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width - 50),
                        Positioned(
                          top: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                RawMaterialButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UploadFile(
                                            userType: "doctor",
                                            imageID:
                                                imgListDoctor.indexOf(item),
                                          ),
                                        ));
                                  },
                                  child: Text("Change"),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                      side: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  elevation: 2.0,
                                  fillColor: Colors.blueGrey,
                                  padding: const EdgeInsets.all(5.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${imgListDoctor.indexOf(item) + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${imgListDoctorTitle[imgListDoctor.indexOf(item)]}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ))
        .toList();

    return SafeArea(
      child: Scaffold(
        //backgroundColor: Theme.of(context).primaryColor,

        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Column(children: [
                Container(
                  margin: EdgeInsets.all(5.0),
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Theme.of(context).accentColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Patient's Slider", style: TextStyle(fontSize: 20)),
                      RawMaterialButton(
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadFile(
                                  userType: "patient",
                                  imageID: imgList.length + 1,
                                ),
                              ));

                          loadSliderImages();
                        },
                        child: Text("Add"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor)),
                        elevation: 2.0,
                        fillColor: Colors.blueGrey,
                        padding: const EdgeInsets.all(5.0),
                      )
                    ],
                  ),
                ),
                SizedBox(
                    height: 200,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageSliders.length,
                        itemBuilder: (BuildContext context, int index) {
                          return imageSliders[index];
                        })),
                Container(
                  margin: EdgeInsets.all(5.0),
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Theme.of(context).accentColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Doctor's Slider", style: TextStyle(fontSize: 20)),
                      RawMaterialButton(
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadFile(
                                  userType: "doctor",
                                  imageID: imgListDoctor.length + 1,
                                ),
                              ));

                          loadSliderImages();
                        },
                        child: Text("Add"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor)),
                        elevation: 2.0,
                        fillColor: Colors.blueGrey,
                        padding: const EdgeInsets.all(5.0),
                      )
                    ],
                  ),
                ),
                SizedBox(
                    height: 200,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageSlidersDoctor.length,
                        itemBuilder: (BuildContext context, int index) {
                          return imageSlidersDoctor[index];
                        }))
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

String _loginUserType() {
  if (globals.loginUserType != null) {
    return globals.loginUserType;
  } else
    return '';
}

String _getUserData(type) {
  if (globals.user != null) {
    return globals.user[0][type];
  } else
    return '';
}
