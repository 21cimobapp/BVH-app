import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DatabaseMethods {
  Future<void> addUserInfo(personCode, userData) async {
    Firestore.instance
        .collection("users")
        .document(personCode)
        .setData(userData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> deleteUserInfo(String mobile) async {
    QuerySnapshot userInfoSnapshot = await getUserInfo(mobile);

    for (DocumentSnapshot doc in userInfoSnapshot.documents) {
      doc.reference.delete();
    }
  }

  getUserInfo(String mobile) async {
    return Firestore.instance
        .collection("users")
        .where("mobile", isEqualTo: mobile)
        .getDocuments()
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<QuerySnapshot> getUserInfoByID(String personCode) async {
    return Firestore.instance
        .collection("users")
        .where("userCode", isEqualTo: personCode)
        .getDocuments()
        .catchError((e) {
      print(e.toString());
    });
  }

  // Future<String> getChannelName() async {
  //   DocumentSnapshot snapshot =
  //       await Firestore.instance.collection('channels').document('567890');
  //   String channelName = snapshot['channelName'];
  //   if (channelName is String) {
  //     return channelName;
  //   } else {
  //     return "";
  //   }
  // }

  getUserName(personCode) async {
    String peerName = "";
    await Firestore.instance
        .collection('users')
        .document(personCode)
        .get()
        .then((DocumentSnapshot ds) {
      peerName = ds['userName'];
    });

    return peerName;
  }

  searchByName(String searchField) {
    return Firestore.instance
        .collection("users")
        .where('userName', isEqualTo: searchField)
        .getDocuments();
  }

  Future<bool> addChatRoom(chatRoom, chatRoomId) {
    Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .setData(chatRoom)
        .catchError((e) {
      print(e);
    });
  }

  getChats(String chatRoomId) async {
    return Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future<void> addMessage(String chatRoomId, chatMessageData) {
    Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection("chats")
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getUserChats(String personCode) async {
    return await Firestore.instance
        .collection("chatRoom")
        .where('users', arrayContains: personCode)
        .snapshots();
  }

  Future<bool> addAppointment(apptDetails, apptID) {
    Firestore.instance
        .collection("Appointments")
        .document(apptID)
        .setData(apptDetails)
        .catchError((e) {
      print(e);
    });
  }

  getPatientAppointments(String patientCode) async {
    return Firestore.instance
        .collection("Appointments")
        .where("patientCode", isEqualTo: patientCode)
        .where("doctorSlotToTime", isGreaterThanOrEqualTo: DateTime.now())
        .orderBy("doctorSlotToTime")
        .snapshots();
  }

  getPatientAppointmentsRecent(String patientCode) {
    return Firestore.instance
        .collection("Appointments")
        .where("patientCode", isEqualTo: patientCode)
        .where("doctorSlotToTime", isGreaterThanOrEqualTo: DateTime.now())
        .orderBy("doctorSlotToTime")
        .snapshots();
  }

  getPatientAppointmentsPast(String patientCode) async {
    return Firestore.instance
        .collection("Appointments")
        .where("patientCode", isEqualTo: patientCode)
        .where("doctorSlotToTime", isLessThan: DateTime.now())
        .orderBy("doctorSlotToTime", descending: true)
        .snapshots();
  }

  getDoctorAppointments(String doctorCode, DateTime apptDate) async {
    return Firestore.instance
        .collection("Appointments")
        .where("doctorCode", isEqualTo: doctorCode)
        .where("apptDate", isEqualTo: apptDate)
        .orderBy("doctorSlotFromTime")
        .snapshots();
  }

  getDoctorAppointmentsPending(String doctorCode) async {
    return Firestore.instance
        .collection("Appointments")
        .where("doctorCode", isEqualTo: doctorCode)
        .where("appointmentStatus", isEqualTo: "DONE")
        .where("prescriptionStatus", whereIn: ['PENDING', 'GENERATED'])
        .orderBy("doctorSlotFromTime")
        .snapshots();
  }

  getDoctorAppointmentsWaitingOnly(String doctorCode, DateTime apptDate) async {
    return Firestore.instance
        .collection("Appointments")
        .where("doctorCode", isEqualTo: doctorCode)
        .where("apptDate", isEqualTo: apptDate)
        .where("appointmentStatus", isEqualTo: "WAITING")
        .orderBy("doctorSlotFromTime")
        .snapshots();
  }

  Stream<DocumentSnapshot> getAppointmentDetails(String appointmentNumber) {
    return Firestore.instance
        .collection("Appointments")
        .document(appointmentNumber)
        .snapshots();
  }

  getPatientDocuments(String patientCode, String uploadedBy) async {
    return Firestore.instance
        .collection("eRecords")
        .document(patientCode)
        .collection('Docuements')
        .where("uploadedBy", isEqualTo: uploadedBy)
        .snapshots();
  }

  Future<bool> addPatientDocument(document, patientCode) {
    Firestore.instance
        .collection("eRecords")
        .document(patientCode)
        .collection('Docuements')
        .document("${document["documentCode"]}")
        .setData(document)
        .catchError((e) {
      print(e);
    });
  }

  Future<bool> addSliderImages(document, userType, imageID) {
    Firestore.instance
        .collection("SliderImages")
        .document(userType)
        .collection('Images')
        .document(imageID.toString())
        .setData(document)
        .catchError((e) {
      print(e);
    });
  }

  Future<List<SliderImages>> getSliderImages(userType) async {
    final List<SliderImages> loadedList = [];

    await Firestore.instance
        .collection("SliderImages")
        .document(userType)
        .collection('Images')
        .orderBy("imageID")
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(SliderImages(
              documentName: f.data['documentName'],
              documentTitle: f.data['documentTitle'],
              documentType: f.data['documentType'],
              documentURL: f.data['documentURL'],
              effectiveDate: f.data['effectiveDate'].toDate(),
              imageID: f.data['imageID'],
              uploadedDate: f.data['uploadedDate'].toDate(),
              userType: f.data['userType'],
            )),
          ),
        );
    return loadedList;
  }

  Future<void> updateAppointmentDetails(
      String apptID, String field, String value) {
    String dateField;

    if (field == "appointmentStatus") {
      dateField = "${value}DateTime";

      Firestore.instance
          .collection('Appointments')
          .document(apptID)
          .updateData({
        '$field': value,
        'prescriptionStatus': 'PENDING',
        '$dateField': DateTime.now(),
      });
    } else {
      Firestore.instance
          .collection('Appointments')
          .document(apptID)
          .updateData({
        '$field': value,
      });
    }
  }

  var doctorTodaySummary = Map();

  Future<Map> getDoctorTodaySummary(String doctorCode) async {
    String appointmentStatus = "";
    doctorTodaySummary["Total"] = 0;
    doctorTodaySummary["Done"] = 0;

    await Firestore.instance
        .collection("Appointments")
        .where("doctorCode", isEqualTo: doctorCode)
        .where("apptDate",
            isEqualTo:
                DateFormat('yyyy-MM-dd').parse(DateTime.now().toString()))
        .getDocuments()
        .then((snapshot) {
      return snapshot.documents.map((element) {
        appointmentStatus = element.data['name'];

        if (appointmentStatus == null)
          appointmentStatus = "PENDING";
        else if (appointmentStatus == "CANCELLED")
          appointmentStatus = "";
        else if (appointmentStatus == "DONE")
          appointmentStatus = "DONE";
        else
          appointmentStatus = "DONE";

        if (appointmentStatus == "PENDING") {
          doctorTodaySummary["Total"] += 1;
        } else if (appointmentStatus == "DONE") {
          doctorTodaySummary["Total"] += 1;
          doctorTodaySummary["Done"] += 1;
        }
      }).toList();

      //return doctorTodaySummary;
    });
  }

  Future<void> setPreConsultationMaster(apptID) async {
    await Firestore.instance
        .collection("PreConsultationMaster")
        .orderBy("sequence")
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach((f) => {
                Firestore.instance
                    .collection('Appointments')
                    .document(apptID)
                    .collection('PreConsultationInfo')
                    .document(f.data['id'])
                    .setData({
                  'id': f.data['id'],
                  'question': f.data['question'],
                  'answerType': f.data['answerType'],
                  'answerField1': f.data['answerField1'],
                  'sequence': f.data['sequence'],
                })
              }),
        );
  }

  Future<List<PreConsultationMasterList>> getPreConsultationMaster(
      apptID) async {
    final List<PreConsultationMasterList> loadedList = [];

    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('PreConsultationInfo')
        .orderBy("sequence")
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(PreConsultationMasterList(
              id: f.data['id'],
              question: f.data['question'],
              answerType: f.data['answerType'],
              answerField1: f.data['answerField1'],
              sequence: f.data['sequence'],
              answer1: f.data['answer1'],
              answer2: f.data['answer2'],
            )),
          ),
        );
    return loadedList;
  }

  getPreConsultationDetails(apptID) async {
    return Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('PreConsultationInfo')
        .orderBy("sequence")
        .snapshots();
  }

  Future<void> updatePreConsultationInfo1(
      String apptID,
      String questionID,
      String question,
      String answerType,
      String answerField1,
      int sequence,
      String value) {
    Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('PreConsultationInfo')
        .document(questionID)
        .setData({
      'id': questionID,
      'question': question,
      'answerType': answerType,
      'answerField1': answerField1,
      'sequence': sequence,
      'answer1': value,
    });
    return null;
  }

  Future<void> updatePreConsultationInfo2(
      String apptID,
      String questionID,
      String question,
      String answerType,
      String answerField1,
      int sequence,
      String value) {
    Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('PreConsultationInfo')
        .document(questionID)
        .setData({
      'id': questionID,
      'question': question,
      'answerType': answerType,
      'answerField1': answerField1,
      'sequence': sequence,
      'answer2': value,
    });
    return null;
  }

  Future<void> updatePrescription(ePrescription, apptID) {
    Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .setData(ePrescription);
    return null;
  }

  Future<void> addPrescriptionMedicine(medicine, apptID) {
    Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .collection('medicine')
        .add(medicine);
    return null;
  }

  Future<void> addPrescriptionTest(test, apptID) {
    Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .collection('test')
        .add(test);
    return null;
  }

  Future<void> deletePrescription(ePrescription, apptID) async {
    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .delete();

    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .collection('medicine')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
    });

    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .collection('test')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
    });

    return null;
  }

  Future<List<EPrescription>> getEPrescription(apptID) async {
    final List<EPrescription> loadedList = [];

    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(EPrescription(
              prescriptionDate: f.data['prescriptionDate'].toDate(),
              diagnosis: f.data['diagnosis'],
              history: f.data['history'],
              notes: f.data['notes'],
              followupDate: f.data['followupDate'].toDate(),
            )),
          ),
        );
    return loadedList;
  }

  Future<List<RxMedicine>> getEPrescriptionMedicine(apptID) async {
    final List<RxMedicine> loadedList = [];

    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .collection('medicine')
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(RxMedicine(
              name: f.data['name'],
              dosage: f.data['dosage'],
              frequency: f.data['frequency'],
              timing: f.data['timing'],
              duration: f.data['duration'],
              remark: f.data['remark'],
            )),
          ),
        );
    return loadedList;
  }

  Future<List<RxTest>> getEPrescriptionTest(apptID) async {
    final List<RxTest> loadedList = [];

    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .collection('test')
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(RxTest(
              name: f.data['name'],
              type: f.data['type'],
              instructions: f.data['instructions'],
            )),
          ),
        );
    return loadedList;
  }

  Future<List<List<String>>> getEPrescriptionMedicineRx(apptID) async {
    final List<List<String>> loadedList = [];

    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .collection('medicine')
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(<String>[
              f.data['name'],
              f.data['dosage'],
              f.data['frequency'],
              "f.data['duration'] day(s)",
              "${f.data['timing']} ${f.data['remark']}"
            ]),
          ),
        );
    if (loadedList.length > 0)
      loadedList.insert(0, <String>[
        'Medicine',
        'Dosage',
        'Frequency',
        'Duration',
        'Instructions'
      ]);

    return loadedList;
  }

  Future<List<List<String>>> getEPrescriptionTestRx(apptID) async {
    final List<List<String>> loadedList = [];

    await Firestore.instance
        .collection('Appointments')
        .document(apptID)
        .collection('ePrescription')
        .document(apptID)
        .collection('test')
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(<String>[
              f.data['name'],
              f.data['instructions'],
            ]),
          ),
        );

    if (loadedList.length > 0)
      loadedList.add(<String>[
        'Test Name',
        'Instructions',
      ]);

    return loadedList;
  }

  Future<List<DoctorSpeciality>> getDoctorSpeciality() async {
    final List<DoctorSpeciality> loadedList = [];

    await Firestore.instance
        .collection('Masters')
        .document("Main")
        .collection('DoctorSpeciality')
        .orderBy("sequence")
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(DoctorSpeciality(
              specialityId: f.data['specialityCode'],
              speciality: f.data['speciality'],
              description: f.data['description'],
              sequence: f.data['sequence'],
            )),
          ),
        );
    return loadedList;
  }

  getDoctorSpecialityMaster() async {
    return Firestore.instance
        .collection('Masters')
        .document("Main")
        .collection('DoctorSpeciality')
        .orderBy("sequence")
        .snapshots();
  }

  Future<void> addSpeciality(String specialityCode, specialityData) {
    Firestore.instance
        .collection("Masters")
        .document("Main")
        .collection("DoctorSpeciality")
        .document(specialityCode)
        .setData(specialityData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<List<Services>> getServices() async {
    final List<Services> loadedList = [];

    await Firestore.instance
        .collection('Masters')
        .document("Main")
        .collection('Services')
        .orderBy("sequence")
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(Services(
              serviceId: f.data['serviceId'],
              serviceName: f.data['serviceName'],
              serviceType: f.data['serviceType'],
              description: f.data['description'],
              sequence: f.data['sequence'],
            )),
          ),
        );
    return loadedList;
  }

  getServicesMaster() async {
    return Firestore.instance
        .collection('Masters')
        .document("Main")
        .collection('Services')
        .orderBy("sequence")
        .snapshots();
  }

  Future<void> addServices(String serviceCode, serviceData) {
    Firestore.instance
        .collection("Masters")
        .document("Main")
        .collection("Services")
        .document(serviceCode)
        .setData(serviceData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<List<Medicines>> getMedicines() async {
    final List<Medicines> loadedList = [];

    await Firestore.instance
        .collection('Medicines')
        .document("Main")
        .collection('Medicines')
        .orderBy("sequence")
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(Medicines(
              medicineId: f.data['medicineId'],
              medicineName: f.data['medicineName'],
              medicineType: f.data['medicineType'],
              description: f.data['description'],
              sequence: f.data['sequence'],
            )),
          ),
        );
    return loadedList;
  }

  getMedicinesMaster() async {
    return Firestore.instance
        .collection('Masters')
        .document("Main")
        .collection('Medicines')
        .orderBy("sequence")
        .snapshots();
  }

  Future<void> addMedicines(String serviceCode, serviceData) {
    Firestore.instance
        .collection("Masters")
        .document("Main")
        .collection("Medicines")
        .document(serviceCode)
        .setData(serviceData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<List<DoctorData>> getDoctors(specialityId) async {
    final List<DoctorData> loadedList = [];

    await Firestore.instance
        .collection('Masters')
        .document("Main")
        .collection('Doctors')
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(DoctorData(
              doctorCode: f.data['doctorCode'],
              doctorName: f.data['doctorName'],
              designation: f.data['designation'],
              speciality: f.data['speciality'],
              availableDays: f.data['availableDays'],
              aboutDoctor: f.data['aboutDoctor'],
            )),
          ),
        );
    return loadedList;
  }

  getDoctorsMaster() async {
    return Firestore.instance
        .collection('Masters')
        .document("Main")
        .collection('Doctors')
        .orderBy("doctorName")
        .snapshots();
  }

  Future<void> addDoctors(String doctorCode, doctorData) {
    Firestore.instance
        .collection("Masters")
        .document("Main")
        .collection("Doctors")
        .document(doctorCode)
        .setData(doctorData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<List<HolidayData>> getHolidays() async {
    final List<HolidayData> loadedList = [];

    await Firestore.instance
        .collection('Masters')
        .document("Main")
        .collection('Holiday')
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(HolidayData(
              holidayCode: f.data['holidayCode'],
              holidayDate: f.data['holidayDate'].toDate(),
              holidayDetails: f.data['holidayDetails'],
            )),
          ),
        );
    return loadedList;
  }

  getHolidayMaster() async {
    return Firestore.instance
        .collection('Masters')
        .document("Main")
        .collection('Holiday')
        .snapshots();
  }

  Future<void> addHoliday(String holidayCode, holidayData) {
    Firestore.instance
        .collection("Masters")
        .document("Main")
        .collection("Holiday")
        .document(holidayCode)
        .setData(holidayData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> deleteHoliday(holidayCode) async {
    await Firestore.instance
        .collection("Masters")
        .document("Main")
        .collection("Holiday")
        .document(holidayCode)
        .delete();
  }

  Future<List<DoctorSessions>> getDoctorSessionsMaster(doctorCode) async {
    final List<DoctorSessions> loadedList = [];

    await Firestore.instance
        .collection('Masters')
        .document("Main")
        .collection('DoctorSession')
        .where("doctorCode", isEqualTo: doctorCode)
        .orderBy('sessionTimingID')
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(DoctorSessions(
              sessionID: f.data['sessionID'],
              sessionDay: f.data['sessionDay'],
              sessionTiming: f.data['sessionTiming'],
              consultationFee: f.data['consultationFee'],
              startTime: f.data['startTime'],
              endTime: f.data['endTime'],
              slotDuration: f.data['slotDuration'],
            )),
          ),
        );
    return loadedList;
  }

  Future<List<DoctorNonWorkingDays>> getDoctorNonWorkingMaster(
      doctorCode) async {
    final List<DoctorNonWorkingDays> loadedList = [];

    await Firestore.instance
        .collection('Masters')
        .document("Main")
        .collection('DoctorNonWorking')
        .where("doctorCode", isEqualTo: doctorCode)
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(DoctorNonWorkingDays(
              id: f.documentID,
              fromDate: f.data['fromDate'],
              toDate: f.data['toDate'],
              remark: f.data['remark'],
            )),
          ),
        );
    return loadedList;
  }

  Future<List<DoctorSessions>> getDoctorSessionsForDay(
      doctorCode, sessionDay) async {
    final List<DoctorSessions> loadedList = [];

    await Firestore.instance
        .collection('Masters')
        .document("Main")
        .collection('DoctorSession')
        .where("doctorCode", isEqualTo: doctorCode)
        .where("sessionDay", isEqualTo: sessionDay)
        .orderBy('sessionTimingID')
        .getDocuments()
        .then(
          (QuerySnapshot snapshot) => snapshot.documents.forEach(
            (f) => loadedList.add(DoctorSessions(
              sessionID: f.data['sessionID'],
              sessionDay: f.data['sessionDay'],
              sessionTiming: f.data['sessionTiming'],
              consultationFee: f.data['consultationFee'],
              startTime: f.data['startTime'],
              endTime: f.data['endTime'],
              slotDuration: f.data['slotDuration'],
            )),
          ),
        );
    return loadedList;
  }

  Future<bool> addDoctorSession(doctorCode, doctorSession, sessionID) {
    Firestore.instance
        .collection("Masters")
        .document("Main")
        .collection("DoctorSession")
        .document(sessionID)
        .setData(doctorSession)
        .catchError((e) {
      print(e);
    });
  }

  Future<void> deleteDoctorSession(doctorCode, sessionID) async {
    await Firestore.instance
        .collection("Masters")
        .document("Main")
        .collection("DoctorSession")
        .document(sessionID)
        .delete();
  }

  Future<bool> addNonWorkingSession(doctorCode, doctorSession) {
    Firestore.instance
        .collection("Masters")
        .document("Main")
        .collection("DoctorNonWorking")
        .add(doctorSession)
        .catchError((e) {
      print(e);
    });
  }

  Future<void> deleteNonWorkingSession(doctorCode, id) async {
    await Firestore.instance
        .collection("Masters")
        .document("Main")
        .collection("DoctorSession")
        .document(id)
        .delete();
  }
}

class SliderImages {
  String documentName;
  String documentTitle;
  String documentType;
  String documentURL;
  DateTime effectiveDate;
  int imageID;
  DateTime uploadedDate;
  String userType;

  SliderImages(
      {this.documentName,
      this.documentTitle,
      this.documentType,
      this.documentURL,
      this.effectiveDate,
      this.imageID,
      this.uploadedDate,
      this.userType});

  SliderImages.fromJson(Map<String, dynamic> json) {
    documentName = json["documentName"];
    documentTitle = json["documentTitle"];
    documentType = json["documentType"];
    documentURL = json["documentURL"];
    effectiveDate = json["effectiveDate"];
    imageID = json["imageID"];
    uploadedDate = json["uploadedDate"];
    userType = json["userType"];
  }
}

class DoctorNonWorkingDays {
  String id;
  DateTime fromDate;
  DateTime toDate;
  String remark;

  DoctorNonWorkingDays({
    this.id,
    this.fromDate,
    this.toDate,
    this.remark,
  });

  DoctorNonWorkingDays.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    fromDate = json["fromDate"];
    toDate = json["toDate"];
    remark = json["remark"];
  }
}

class DoctorSessions {
  String sessionID;
  String sessionDay;
  String sessionTiming;
  int consultationFee;
  String startTime;
  String endTime;
  int slotDuration;

  DoctorSessions(
      {this.sessionID,
      this.sessionDay,
      this.sessionTiming,
      this.consultationFee,
      this.startTime,
      this.endTime,
      this.slotDuration});

  DoctorSessions.fromJson(Map<String, dynamic> json) {
    sessionID = json["sessionID"];
    sessionDay = json["sessionDay"];
    sessionTiming = json["sessionTiming"];
    consultationFee = json["consultationFee"];
    startTime = json["startTime"];
    endTime = json["endTime"];
    slotDuration = json["slotDuration"];
  }
}

class DoctorData {
  String doctorCode;
  String doctorName;
  String designation;
  String specialityCode;
  String speciality;
  String availableDays;
  String aboutDoctor;

  DoctorData({
    this.doctorCode,
    this.doctorName,
    this.designation,
    this.specialityCode,
    this.speciality,
    this.availableDays,
    this.aboutDoctor,
  });

  DoctorData.fromJson(Map<String, dynamic> json) {
    doctorCode = json["doctorCode"];
    doctorName = json["doctorName"];
    designation = json["designation"];
    specialityCode = json["specialityCode"];
    speciality = json["speciality"];
    availableDays = json["availableDays"];
    aboutDoctor = json["aboutDoctor"];
  }
}

class Services {
  final String serviceId;
  final String serviceName;
  final String serviceType;
  final String description;
  final int sequence;

  Services({
    this.serviceId,
    this.serviceName,
    this.serviceType,
    this.description,
    this.sequence,
  });
}

class Medicines {
  final String medicineId;
  final String medicineName;
  final String medicineType;
  final String description;
  final int sequence;

  Medicines({
    this.medicineId,
    this.medicineName,
    this.medicineType,
    this.description,
    this.sequence,
  });
}

class DoctorSpeciality {
  final String specialityId;
  final String speciality;
  final String description;
  final int sequence;

  DoctorSpeciality({
    this.specialityId,
    this.speciality,
    this.description,
    this.sequence,
  });
}

class PreConsultationMasterList {
  final String id;
  final String question;
  final String answerType;
  final String answerField1;
  final int sequence;
  String answer1;
  String answer2;

  PreConsultationMasterList(
      {this.id,
      this.question,
      this.answerType,
      this.answerField1,
      this.sequence,
      this.answer1,
      this.answer2});
}

class EPrescription {
  DateTime prescriptionDate;
  String diagnosis;
  String history;
  String notes;
  DateTime followupDate;

  EPrescription({
    this.prescriptionDate,
    this.diagnosis,
    this.history,
    this.notes,
    this.followupDate,
  });
}

class RxMedicine {
  String name;
  String dosage;
  String frequency;
  String timing;
  String duration;
  String remark;

  RxMedicine({
    this.name,
    this.dosage,
    this.frequency,
    this.timing,
    this.duration,
    this.remark,
  });
}

class RxTest {
  String name;
  String type;
  String instructions;

  RxTest({
    this.name,
    this.type,
    this.instructions,
  });
}

class HolidayData {
  String holidayCode;
  DateTime holidayDate;
  String holidayDetails;

  HolidayData({
    this.holidayCode,
    this.holidayDate,
    this.holidayDetails,
  });
}
