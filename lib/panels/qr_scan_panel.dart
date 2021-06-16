import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/admin_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as Scanner;

class QRScannerPanel extends StatefulWidget {
  @override
  _QRScannerPanelState createState() => _QRScannerPanelState();
}

class _QRScannerPanelState extends State<QRScannerPanel>
    with AfterLayoutMixin<QRScannerPanel> {
  bool showCorner = false;

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
    String qrContent = await Scanner.scan() as String;
    if (qrContent == null) Get.off(AdminPanel());
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
    startTimer();
  }

  startTimer() {
    var duration = Duration(milliseconds: 300);
    Timer(duration, showCorners);
  }

  showCorners() {
    setState(() {
      showCorner = true;
    });
  }
}
