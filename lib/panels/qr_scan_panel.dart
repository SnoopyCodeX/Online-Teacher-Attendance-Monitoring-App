import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/staff.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/admin_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/services/firestore_service.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:qrscan/qrscan.dart' as Scanner;

class AdminQRScannerPanel extends StatefulWidget {
  @override
  _AdminQRScannerPanelState createState() => _AdminQRScannerPanelState();
}

class _AdminQRScannerPanelState extends State<AdminQRScannerPanel>
    with SingleTickerProviderStateMixin, AfterLayoutMixin<AdminQRScannerPanel> {
  TextEditingController? _loginController;
  bool showCorner = false;

  @override
  void initState() {
    super.initState();

    _loginController = new TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    _loginController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: primaryColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Login as Admin',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Properly align the box with your qr code and make sure to focus your camera.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                TextFormField(
                  controller: _loginController,
                  decoration: InputDecoration(
                    suffixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.black54,
                    ),
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    filled: true,
                    hintStyle: new TextStyle(color: Colors.black54),
                    hintText: "Type email address",
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'TAP HERE TO SCAN',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.aBeeZee(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Center(
                      child: MaterialButton(
                        onPressed: () => _scanQRCode(),
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            getCorners(),
                            Image.asset(
                              'images/qrcode.png',
                              width: 140.0,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _scanQRCode() async {
    await Permission.camera.request();
    String qrContent = await Scanner.scan();

    if (qrContent != null || qrContent.isNotEmpty) {
      String email = _loginController!.text;

      if (!email.isEmail || email.isEmpty) {
        Get.snackbar(
          'Login Failed',
          'You entered an invalid email address!',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      List<Staff> data = await showDialog(
        context: context,
        builder: (context) => FutureProgressDialog(
          FirestoreService().getStaff('email_address', email),
          message: Text("Verifying login..."),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
      );
      if (data.length == 1) {
        if (data[0].systemRole != 1) {
          Get.snackbar(
            'Login Failed',
            'You are not authorized to login as an admin!',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackStyle: SnackStyle.FLOATING,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        if (DBCrypt().checkpw(qrContent, data[0].qrCode)) {
          Map<String, dynamic> json = data[0].toMap();
          json['is_active'] = true;

          await showDialog(
            context: context,
            builder: (context) => FutureProgressDialog(
              FirestoreService().setStaff(Staff.fromJson(json)),
              message: Text("Logging in..."),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
            ),
          );

          await Cache.write('data', json);
          Get.offAll(() => AdminPanel(admin: data[0]));
        } else
          Get.snackbar(
            'Login Failed',
            'Your qrcode does not match with the one registered in the system!',
            backgroundColor: Colors.deepOrangeAccent,
            colorText: Colors.white,
            snackStyle: SnackStyle.FLOATING,
            snackPosition: SnackPosition.BOTTOM,
          );
      } else {
        Get.snackbar(
          'Login Failed',
          'Email address does not exist!',
          backgroundColor: Colors.deepOrangeAccent,
          colorText: Colors.white,
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Widget getCorners() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      width: showCorner ? 140 : 80,
      height: showCorner ? 140 : 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisSize: showCorner ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RotatedBox(
                  quarterTurns: 0,
                  child: Image.asset(
                    "images/corners.png",
                    width: 25.0,
                  )),
              RotatedBox(
                  quarterTurns: 1,
                  child: Image.asset(
                    "images/corners.png",
                    width: 25.0,
                  )),
            ],
          ),
          Spacer(),
          Row(
            mainAxisSize: showCorner ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RotatedBox(
                  quarterTurns: 3,
                  child: Image.asset(
                    "images/corners.png",
                    width: 25.0,
                  )),
              RotatedBox(
                  quarterTurns: 2,
                  child: Image.asset(
                    "images/corners.png",
                    width: 25.0,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _startTimer();
  }

  _startTimer() {
    var duration = Duration(milliseconds: 300);
    Timer(duration, _showCorners);
  }

  _showCorners() {
    setState(() {
      showCorner = true;
    });
  }
}

class TeacherQRScannerPanel extends StatefulWidget {
  @override
  _TeacherQRScannerPanelState createState() => _TeacherQRScannerPanelState();
}

class _TeacherQRScannerPanelState extends State<TeacherQRScannerPanel>
    with
        SingleTickerProviderStateMixin,
        AfterLayoutMixin<TeacherQRScannerPanel> {
  bool showCorner = false;
  TextEditingController? _loginController;

  @override
  void initState() {
    super.initState();

    _loginController = new TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    _loginController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: primaryColor,
      body: Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Scan QR Code to Log In.',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Properly align the box with your qr code and make sure to focus your camera.',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: 100,
              ),
              TextFormField(
                controller: _loginController,
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.black54,
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
                  filled: true,
                  hintStyle: new TextStyle(color: Colors.black54),
                  hintText: "Type email address",
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'TAP HERE TO SCAN',
                textAlign: TextAlign.center,
                style: GoogleFonts.aBeeZee(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Center(
                    child: MaterialButton(
                      onPressed: () => _scanQRCode(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          getCorners(),
                          Image.asset(
                            'images/qrcode.png',
                            width: 140.0,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future _scanQRCode() async {
    await Permission.camera.request();
    String qrContent = await Scanner.scan();

    if (qrContent != null || qrContent.isNotEmpty) {
      String email = _loginController!.text;

      if (!email.isEmail || email.isEmpty) {
        Get.snackbar(
          'Login Failed',
          'You entered an invalid email address!',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      List<Staff> data = await showDialog(
        context: context,
        builder: (context) => FutureProgressDialog(
          FirestoreService().getStaff('email_address', email),
          message: Text("Verifying login..."),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
      );

      Navigator.of(context).pop(false);
      if (data.length == 1) {
        if (DBCrypt().checkpw(qrContent, data[0].qrCode)) {
          Map<String, dynamic> json = data[0].toMap();
          json['is_active'] = true;

          await showDialog(
            context: context,
            builder: (context) => FutureProgressDialog(
              FirestoreService().setStaff(Staff.fromJson(json)),
              message: Text("Logging in..."),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
            ),
          );

          await Cache.write('data', json);
          Get.offAll(() => AdminPanel(admin: data[0]));
        } else
          Get.snackbar(
            'Login Failed',
            'Your qrcode does not match with the one registered in the system!',
            backgroundColor: Colors.deepOrangeAccent,
            colorText: Colors.white,
            snackStyle: SnackStyle.FLOATING,
            snackPosition: SnackPosition.BOTTOM,
          );
      } else {
        Get.snackbar(
          'Login Failed',
          'Email address does not exist!',
          backgroundColor: Colors.deepOrangeAccent,
          colorText: Colors.white,
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Widget getCorners() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      width: showCorner ? 140 : 80,
      height: showCorner ? 140 : 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisSize: showCorner ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RotatedBox(
                  quarterTurns: 0,
                  child: Image.asset(
                    "images/corners.png",
                    width: 25.0,
                  )),
              RotatedBox(
                  quarterTurns: 1,
                  child: Image.asset(
                    "images/corners.png",
                    width: 25.0,
                  )),
            ],
          ),
          Spacer(),
          Row(
            mainAxisSize: showCorner ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RotatedBox(
                  quarterTurns: 3,
                  child: Image.asset(
                    "images/corners.png",
                    width: 25.0,
                  )),
              RotatedBox(
                  quarterTurns: 2,
                  child: Image.asset(
                    "images/corners.png",
                    width: 25.0,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _startTimer();
  }

  _startTimer() {
    var duration = Duration(milliseconds: 300);
    Timer(duration, _showCorners);
  }

  _showCorners() {
    setState(() {
      showCorner = true;
    });
  }
}
