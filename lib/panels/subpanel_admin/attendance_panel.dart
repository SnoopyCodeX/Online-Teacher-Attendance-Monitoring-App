import 'package:flutter/material.dart';

class AdminAttendanceListPanel extends StatefulWidget {
  @override
  _AdminAttendanceListPanelState createState() =>
      _AdminAttendanceListPanelState();
}

class _AdminAttendanceListPanelState extends State<AdminAttendanceListPanel> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text('Attendance'),
      ),
    );
  }
}
