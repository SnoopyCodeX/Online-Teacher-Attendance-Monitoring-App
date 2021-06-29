import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/staff.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/admin_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/subpanel_teacher/home_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/services/firestore_service.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:qrscan/qrscan.dart' as Scanner;
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

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
      body: SingleChildScrollView(
        child: GestureDetector(
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
                  TextField(
                    controller: _loginController,
                    style: GoogleFonts.poppins(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.white,
                      ),
                      enabledBorder: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(8.0),
                        ),
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      focusedBorder: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(8.0),
                        ),
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      hintText: "Type email address",
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
                          onPressed: () async => await _scanQRCode(),
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
      ),
    );
  }

  Future _scanQRCode() async {
    print("Scan QR Code button");
    await Permission.storage.request();
    await Permission.camera.request();
    String qrContent = await Scanner.scan();

    if (qrContent.isNotEmpty) {
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

      ProgressDialog pd = ProgressDialog(context: context);
      pd.show(
        max: 100,
        msg: 'Verifying login...',
        progressType: ProgressType.valuable,
      );
      List<Staff> data =
          await FirestoreService().getStaff('email_address', email);
      pd.close();

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

          pd.show(
            max: 100,
            msg: 'Logging in...',
            progressType: ProgressType.valuable,
          );

          await Cache.write('data', json);
          pd.close();
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
      body: SingleChildScrollView(
        child: GestureDetector(
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
                    'Login as Teacher',
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
                  TextField(
                    controller: _loginController,
                    style: GoogleFonts.poppins(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.white,
                      ),
                      enabledBorder: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(8.0),
                        ),
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      focusedBorder: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(8.0),
                        ),
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      hintText: "Type email address",
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
      ),
    );
  }

  Future _scanQRCode() async {
    await Permission.storage.request();
    await Permission.camera.request();
    String qrContent = await Scanner.scan();

    if (qrContent.isNotEmpty) {
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

      ProgressDialog pd = ProgressDialog(context: context);
      pd.show(
        max: 100,
        msg: 'Verifying login...',
        progressType: ProgressType.valuable,
      );
      List<Staff> data =
          await FirestoreService().getStaff('email_address', email);
      pd.close();

      if (data.length == 1) {
        if (DBCrypt().checkpw(qrContent, data[0].qrCode)) {
          Map<String, dynamic> json = data[0].toMap();

          json['logged_as'] = 0;
          await Cache.write('data', json);

          pd.close();
          Get.offAll(() => TeacherHomePanel(teacher: data[0]));
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
