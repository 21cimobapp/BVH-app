library my_prj.globals;

//import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//import 'package:flutter_callkeep/flutter_callkeep.dart';

List user;
String loginUserType;
String personCode;
String personName;
String msgRTM;
bool isLogin = false;
//AgoraRtmClient clientRTM;

Color appMainColor = Color(0xFF128C7E);
Color appTextColor = Colors.white;
Color appSecondColor = Color(0xff4bb17b);

final apiHostingURL = "http://patient.bhaktivedantahospital.com/MobileAppEx";

List<bool> dayToShow = [true, true, true, true, true, true, true];
