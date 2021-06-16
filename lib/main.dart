import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/login_panel.dart';

void main() => runApp(new AttendanceApp());

class AttendanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      title: 'Attendance Monitoring App',
      home: new LoginPanel(),
    );
  }
}
