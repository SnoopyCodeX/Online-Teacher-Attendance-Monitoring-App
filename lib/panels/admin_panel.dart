import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as Scanner;

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  Uint8List? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Icon(
          Icons.add_moderator_outlined,
          color: Colors.white,
        ),
        title: Text(
          'Admin Panel',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        backgroundColor: logoGreen,
        child: Icon(
          Icons.app_registration_outlined,
          color: Colors.white,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
          ),
          Stack(
            children: [
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          RotatedBox(
                            quarterTurns: 0,
                            child: Image.asset(
                              "images/corners.png",
                              width: 25.0,
                            ),
                          ),
                          RotatedBox(
                            quarterTurns: 1,
                            child: Image.asset(
                              "images/corners.png",
                              width: 25.0,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          RotatedBox(
                            quarterTurns: 3,
                            child: Image.asset(
                              "images/corners.png",
                              width: 25.0,
                            ),
                          ),
                          RotatedBox(
                            quarterTurns: 2,
                            child: Image.asset(
                              "images/corners.png",
                              width: 25.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              imageUrl != null
                  ? Center(
                      child: imageUrl != null
                          ? Container(
                              padding: EdgeInsets.only(top: 10),
                              width: 190,
                              height: 190,
                              child: Image.memory(imageUrl
                                  as Uint8List), /* PrettyQr(
                                typeNumber: null,
                                elementColor: Colors.white,
                                size: 300,
                                data: 'Sample data to be converted to QR Code',
                                roundEdges: true,
                                errorCorrectLevel: QrErrorCorrectLevel.M,
                              ), */
                            )
                          : Container(),
                    )
                  : Container()
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: MaterialButton(
              onPressed: () => _generateQRCode(),
              padding: EdgeInsets.all(10),
              color: logoGreen,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_2_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Generate QR Code',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: MaterialButton(
              onPressed: () => _saveQRCode(),
              padding: EdgeInsets.all(10),
              color: logoGreen,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.memory_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Save QR Code',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future _generateQRCode() async {
    Uint8List result =
        await Scanner.generateBarCode('Sample data to be converted to QR Code');
    setState(() {
      imageUrl = result;
    });
  }

  Future _saveQRCode() async {
    await Permission.storage.request();
    if (imageUrl != null) {
      final result = await ImageGallerySaver.saveImage(imageUrl as Uint8List,
          name: 'Login QRCode');

      if (result != null && result['isSuccess']) {
        Get.defaultDialog(
          title: 'QRCode Saved',
          content: Text(
            'Your QR Code has been successfully saved to your gallery. Do not share it with anyone and do not lose it.',
          ),
        );
        setState(() {
          this.imageUrl = null;
        });
      } else
        Get.snackbar('QRCode', 'Failed to save your QR Code to your gallery.');
    }
  }
}
