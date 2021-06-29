import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/staff.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/admin_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/qr_scan_panel.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:online_teacher_staff_attendance_monitoring_app/panels/subpanel_teacher/home_panel.dart';

class LoginPanel extends StatefulWidget {
  @override
  _LoginPanelState createState() => _LoginPanelState();
}

class _LoginPanelState extends State<LoginPanel>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    _checkLogin();
  }

  Future _checkLogin() async {
    Map<String, dynamic> staff = await Cache.load('data', <String, dynamic>{});

    if (staff.isNotEmpty) {
      if (staff['system_role'] == 1 && staff['logged_as'] == null)
        Get.offAll(() => AdminPanel(admin: Staff.fromJson(staff)));
      else
        Get.offAll(() => TeacherHomePanel(teacher: Staff.fromJson(staff)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 100, bottom: 20),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'images/illustration_scanning_qr_code.jpg',
                height: 250,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Welcome Back",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'To login, you must scan your personal QR Code that is uniquely generated for your account.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                height: 90,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: OutlinedButton(
                  onPressed: () => Get.to(() => TeacherQRScannerPanel()),
                  style: OutlinedButton.styleFrom(
                    fixedSize: Size(
                      MediaQuery.of(context).size.width,
                      50,
                    ),
                    side: BorderSide(
                      color: Colors.blueAccent,
                      width: 1.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                  ),
                  child: Text(
                    'Login as Teacher',
                    style: GoogleFonts.poppins(
                      color: Colors.blueAccent,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ElevatedButton(
                  onPressed: () => Get.to(() => AdminQRScannerPanel()),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(
                      MediaQuery.of(context).size.width,
                      50,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                  ),
                  child: Text(
                    'Login as Admin',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
