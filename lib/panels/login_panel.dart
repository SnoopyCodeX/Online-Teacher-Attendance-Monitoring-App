import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/staff.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/admin_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/qr_scan_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/utils/constants.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;

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
      if (staff['system_role'] == 1)
        Get.offAll(() => AdminPanel(admin: Staff.fromJson(staff)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
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
              style: TextStyle(
                color: Colors.black,
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
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: MaterialButton(
                elevation: 0,
                height: 50,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => AdminQRScannerPanel()));
                },
                color: logoGreen,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Login as Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
                textColor: Colors.white,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: MaterialButton(
                elevation: 0,
                height: 50,
                onPressed: () {
                  Get.snackbar(
                    'Not Ready',
                    'This function is not yet implemented!',
                    backgroundColor: Colors.deepOrangeAccent,
                    colorText: Colors.white,
                    snackStyle: SnackStyle.FLOATING,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TeacherQRScannerPanel()));
                },
                color: logoGreen,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Login as Teacher',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
                textColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
