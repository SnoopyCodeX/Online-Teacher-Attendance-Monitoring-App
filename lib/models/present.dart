class Present {
  final String id;
  final String staffId;
  final String firstName;
  final String lastName;
  final String middleName;
  final String profileUrl;
  final String presentDate;
  final String presentTime;

  Present({
    required this.id,
    required this.staffId,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.profileUrl,
    required this.presentDate,
    required this.presentTime,
  });

  String get getId => id;
  String get getStaffId => staffId;
  String get getFirstName => firstName;
  String get getLastName => lastName;
  String get getMiddleName => middleName;
  String get getProfileUrl => profileUrl;
  String get getLateDate => presentDate;
  String get getPresentTime => presentTime;

  factory Present.fromJson(Map<String, dynamic> json) {
    return Present(
      id: json['id'],
      staffId: json['staff_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      middleName: json['middle_name'],
      profileUrl: json['profile_url'],
      presentDate: json['present_date'],
      presentTime: json['present_time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'staff_id': this.staffId,
      'first_name': this.firstName,
      'last_name': this.lastName,
      'middle_name': this.middleName,
      'profile_url': this.profileUrl,
      'present_date': this.presentDate,
      'present_time': this.presentTime,
    };
  }
}
