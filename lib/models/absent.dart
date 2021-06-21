class Absent {
  final String id;
  final String staffId;
  final String absentDate;

  Absent({
    required this.id,
    required this.staffId,
    required this.absentDate,
  });

  String get getId => id;
  String get getStaffId => staffId;
  String get getAbsentDate => absentDate;

  factory Absent.fromJson(Map<String, dynamic> json) {
    return Absent(
      id: json['id'],
      staffId: json['staff_id'],
      absentDate: json['absent_date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'staff_id': this.staffId,
      'absent_date': this.absentDate
    };
  }
}
