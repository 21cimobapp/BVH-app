class PatientAppointmentdetails {
  String PatientCode;
  String PatientName;
  String DoctorCode;
  String DoctorName;
  String DoctorDesignation;
  DateTime ApptDate;
  String SlotName;
  String SlotNumber;
  String DoctorSlotFromTime;
  String DoctorSlotToTime;
  String SlotTimeLabel;
  String AppointmentType;
  String SlotDuration;

  PatientAppointmentdetails(
    this.PatientCode,
    this.PatientName,
    this.DoctorCode,
    this.DoctorName,
    this.DoctorDesignation,
    this.ApptDate,
    this.SlotName,
    this.SlotNumber,
    this.DoctorSlotFromTime,
    this.DoctorSlotToTime,
    this.SlotTimeLabel,
    this.AppointmentType,
    this.SlotDuration,
  );
  // PatientAppointmentdetails.fromJson(Map<String, dynamic> json) {
  //   PatientCode = json["PatientCode"];
  //   PatientName = json["PatientName"];
  //   DoctorCode = json["DoctorCode"];
  //   DoctorName = json["DoctorName"];
  //   DoctorDesignation = json["DoctorDesignation"];
  //   ApptDate = json["ApptDate"];
  //   SlotName = json["SlotName"];
  //   SlotNumber = json["SlotNumber"];
  //   DoctorSlotFromTime = json["DoctorSlotFromTime"];
  //   DoctorSlotToTime = json["DoctorSlotToTime"];
  //   SlotTimeLabel = json["SlotTimeLabel"];
  //   AppointmentType = json["AppointmentType"];
  // }
}

class PatientAppointment {
  String SlotAvailable;
  String DoctorTimingSlotName;
  String DoctorSlotFromTime;
  String DoctorSlotToTime;
  String SlotTimeLabel;
  String AppointmentType;
  String SlotDuration;
  String SlotNumber;

  PatientAppointment(
      this.SlotAvailable,
      this.DoctorTimingSlotName,
      this.DoctorSlotFromTime,
      this.DoctorSlotToTime,
      this.SlotTimeLabel,
      this.AppointmentType,
      this.SlotDuration,
      this.SlotNumber);

  PatientAppointment.fromJson(Map<String, dynamic> json) {
    SlotAvailable = json["SlotAvailable"];
    DoctorTimingSlotName = json["DoctorTimingSlotName"];
    DoctorSlotFromTime = json["DoctorSlotFromTime"];
    DoctorSlotToTime = json["DoctorSlotToTime"];
    SlotTimeLabel = json["SlotTimeLabel"];
    AppointmentType = json["AppointmentType"];
    SlotDuration = json["SlotDuration"];
    SlotNumber = json["SlotNumber"];
  }
}
