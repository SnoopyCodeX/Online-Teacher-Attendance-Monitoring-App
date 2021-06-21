class Late {
  final String id;
  final String staffId;
  final String lateDate;

  Late({
    required this.id,
    required this.staffId,
    required this.lateDate,
  });

  String get getId => id;
  String get getStaffId => staffId;
  String get getLateDate => lateDate;

  factory Late.fromJson(Map<String, dynamic> json) {
    return Late(
      id: json['id'],
      staffId: json['staff_id'],
      lateDate: json['late_date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'staff_id': this.staffId,
      'late_date': this.lateDate
    };
  }
}
