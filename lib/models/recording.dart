class Recording {
  String id;
  String patientName;
  String mrnNumber;
  String file;
  DateTime createdOn;
  String date;
  String userId;
  String to;
  String sendType;
  String shareme;

  static List<Recording> listFromMap(List<dynamic> json) {
    return List<Recording>.from(
      json.map(
        (x) => Recording.fromMap(x),
      ),
    );
  }

  Recording({
    required this.id,
    required this.patientName,
    required this.mrnNumber,
    required this.file,
    required this.createdOn,
    required this.date,
    required this.userId,
    required this.to,
    required this.sendType,
    required this.shareme,
  });

  String get name => this.file.split('/').last;

  factory Recording.fromMap(Map<String, dynamic> json) => Recording(
        id: json["id"],
        patientName: json["patient_name"],
        mrnNumber: json["mrn_number"],
        file: json["file"],
        createdOn: DateTime.parse(json["created_on"]),
        date: json["date"] ?? '',
        userId: json["user_id"],
        to: json["to"],
        sendType: json["send_type"],
        shareme: json['shareme'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "patient_name": patientName,
        "mrn_number": mrnNumber,
        "file": file,
        "created_on": createdOn.toIso8601String(),
        // "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "user_id": userId,
        "to": to,
        "send_type": sendType,
      };
}
