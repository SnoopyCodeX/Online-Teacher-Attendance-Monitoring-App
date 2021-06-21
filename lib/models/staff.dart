class Staff {
  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String contactNumber;
  final String emailAddress;
  final String homeAddress;
  final String profileUrl;
  final String qrCode;
  final String lastIn;
  final String lastOut;
  final bool isActive;
  final int systemRole;

  Staff({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.contactNumber,
    required this.emailAddress,
    required this.homeAddress,
    required this.profileUrl,
    required this.qrCode,
    required this.lastIn,
    required this.lastOut,
    required this.isActive,
    required this.systemRole,
  });

  String get getId => id;
  String get getFirstName => firstName;
  String get getMiddleName => middleName;
  String get getLastName => lastName;
  String get getContactNumber => contactNumber;
  String get getEmailAddress => emailAddress;
  String get getHomeAddress => homeAddress;
  String get getProfileUrl => profileUrl;
  String get getQrCode => qrCode;
  String get getLastIn => lastIn;
  String get getLastOut => lastOut;
  bool get getIsActive => isActive;
  int get getSystemRole => systemRole;

  static Staff create() {
    return Staff(
      id: '',
      firstName: '',
      middleName: '',
      lastName: '',
      contactNumber: '',
      emailAddress: '',
      homeAddress: '',
      profileUrl: '',
      qrCode: '',
      lastIn: '',
      lastOut: '',
      isActive: false,
      systemRole: 0,
    );
  }

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      middleName: json['middle_name'] as String,
      lastName: json['last_name'] as String,
      contactNumber: json['contact_number'] as String,
      emailAddress: json['email_address'] as String,
      homeAddress: json['home_address'] as String,
      profileUrl: json['profile_url'] as String,
      qrCode: json['qrcode'] as String,
      lastIn: json['last_in'] as String,
      lastOut: json['last_out'] as String,
      isActive: json['is_active'] as bool,
      systemRole: json['system_role'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'first_name': this.firstName,
      'middle_name': this.middleName,
      'last_name': this.lastName,
      'contact_number': this.contactNumber,
      'email_address': this.emailAddress,
      'home_address': this.homeAddress,
      'profile_url': this.profileUrl,
      'qrcode': this.qrCode,
      'last_in': this.lastIn,
      'last_out': this.lastOut,
      'is_active': this.isActive,
      'system_role': this.systemRole
    };
  }
}
