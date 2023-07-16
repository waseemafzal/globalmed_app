class User {
  String userId;
  String name;
  String userType;
  String email;
  String profilePic;
  String referalCode;
  String accessToken;
  String password;
  String address;
  String clinic_name;
  String phone;
  String specialty;

  User({
    required this.userId,
    required this.name,
    required this.userType,
    required this.email,
    required this.profilePic,
    required this.referalCode,
    required this.accessToken,
    required this.address,
    required this.clinic_name,
    required this.phone,
    this.password = '',
    required this.specialty,
  });

  factory User.fromMap(Map<String, dynamic> json) => User(
        userId: json["user_id"],
        name: json["name"],
        userType: json["user_type"],
        email: json["email"],
        profilePic: json["profilePic"],
        referalCode: json["referal_code"],
        accessToken: json["access_token"],
        address: json['address'],
        clinic_name: json['clinic_name'] ?? '',
        phone: json['phone'] ?? '',
        specialty: json['speciality'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "user_id": userId,
        "name": name,
        "user_type": userType,
        "email": email,
        "profilePic": profilePic,
        "referal_code": referalCode,
        "access_token": accessToken,
        'password': password,
        'address': address,
        'clinic_name': clinic_name,
        'phone': phone,
        'specialty': specialty,
      };
}
