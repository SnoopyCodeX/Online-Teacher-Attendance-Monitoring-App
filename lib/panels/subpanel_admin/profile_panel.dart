import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/staff.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/services/firestore_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:qrscan/qrscan.dart' as QRScanner;

class AdminProfilePanel extends StatefulWidget {
  final Staff admin;

  AdminProfilePanel({required this.admin});

  @override
  _AdminProfilePanelState createState() => _AdminProfilePanelState(this.admin);
}

class _AdminProfilePanelState extends State<AdminProfilePanel>
    with SingleTickerProviderStateMixin {
  TextEditingController? _firstName,
      _middleName,
      _lastName,
      _email,
      _number,
      _address;

  File? pickedImage;
  bool changedPhoto = false;
  final Staff admin;

  _AdminProfilePanelState(this.admin);

  @override
  void initState() {
    super.initState();

    this._firstName = new TextEditingController(text: admin.firstName);
    this._middleName = new TextEditingController(text: admin.middleName);
    this._lastName = new TextEditingController(text: admin.lastName);
    this._email = new TextEditingController(text: admin.emailAddress);
    this._number = new TextEditingController(text: admin.contactNumber);
    this._address = new TextEditingController(text: admin.homeAddress);
  }

  @override
  void dispose() {
    super.dispose();

    this._firstName?.dispose();
    this._middleName?.dispose();
    this._lastName?.dispose();
    this._email?.dispose();
    this._number?.dispose();
    this._address?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 10,
          ),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView(
              children: <Widget>[
                Text(
                  "Edit Profile",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                Center(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 5,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.1),
                              offset: Offset(0, 10),
                            )
                          ],
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: changedPhoto
                                ? Image.file(pickedImage as File).image
                                : NetworkImage(admin.profileUrl.isNotEmpty
                                    ? admin.profileUrl
                                    : "https://firebasestorage.googleapis.com/v0/b/attendance-monitoring-ap-c02d7.appspot.com/o/images%2Ficons%2Fperson.png?alt=media&token=fa5dc920-282c-4d42-83fa-bfce4aebe947"),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 46,
                          width: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueAccent,
                            border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () => _pickProfileImage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                _buildTextField(
                  _firstName,
                  'First name',
                  'Admin\'s first name',
                  Icons.person_outline,
                ),
                _buildTextField(
                  _middleName,
                  'Middle name',
                  'Admin\'s middle name',
                  Icons.person_outline,
                ),
                _buildTextField(
                  _lastName,
                  'Last name',
                  'Admin\'s last name',
                  Icons.person_outline,
                ),
                _buildTextField(
                  _email,
                  'Email address',
                  'Admin\'s email address',
                  Icons.email_outlined,
                ),
                _buildTextField(
                  _number,
                  'Contact number',
                  'Admin\'s contact number',
                  Icons.phone_android_outlined,
                ),
                _buildTextField(
                  _address,
                  'Home adddress',
                  'Admin\'s home address',
                  Icons.location_city_outlined,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    OutlinedButton(
                      onPressed: () => _saveQRCode(),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Text(
                        'Save QRCode',
                        style: GoogleFonts.poppins(
                          color: Colors.teal.shade900,
                          fontSize: 14,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => _saveProfile(),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Text(
                        'Save',
                        style: GoogleFonts.poppins(
                          color: Colors.blueAccent,
                          fontSize: 14,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _saveProfile() async {
    Map<String, dynamic> json = this.admin.toMap();
    if (changedPhoto)
      json['profile_url'] = await _uploadImage(Staff.fromJson(json));

    json['first_name'] = _firstName!.text;
    json['middle_name'] = _middleName!.text;
    json['last_name'] = _lastName!.text;
    json['email_address'] = _email!.text;
    json['home_address'] = _address!.text;
    json['contact_number'] = _number!.text;

    Staff _staff = Staff.fromJson(json);

    await showDialog(
      context: context,
      builder: (context) => FutureProgressDialog(
        FirestoreService().setStaff(_staff),
        message: Text("Saving profile..."),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
    );

    Get.snackbar(
      'Save Success',
      'Profile has been successfully updated!',
      backgroundColor: Colors.greenAccent,
      colorText: Colors.white,
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
    );

    Cache.write('data', json);
    Navigator.of(context).pop(true);
  }

  Future _pickProfileImage() async {
    await Permission.storage.request();
    await Permission.camera.request();
    ImageSource? imageProvider;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload Image'),
        content: Text('Please select where you want to pick your image.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              imageProvider = ImageSource.gallery;
              Navigator.of(context).pop(false);
            },
            child: Text(
              'Gallery',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              imageProvider = ImageSource.camera;
              Navigator.of(context).pop(false);
            },
            child: Text(
              'Camera',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );

    if (imageProvider != null) {
      LostData lost = LostData();
      PickedFile? file = await ImagePicker().getImage(
        source: imageProvider as ImageSource,
      );

      if (file != null) {
        setState(() {
          pickedImage = File(file.path);
          changedPhoto = true;
        });

        return;
      } else if (file == null) {
        lost = await ImagePicker().getLostData();
        if (lost.isEmpty || lost.file == null)
          Get.snackbar(
            'Pick Failed',
            'You did not pick an image!',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackStyle: SnackStyle.FLOATING,
            snackPosition: SnackPosition.BOTTOM,
          );
        else {
          setState(() {
            pickedImage = File(lost.file!.path);
            changedPhoto = true;
          });
        }
      }
    }
  }

  Future _uploadImage(Staff staff) async {
    if (pickedImage == null) return;

    Map<String, dynamic> json = staff.toMap();
    json['profile_url'] = await FirestoreService().uploadImage(
      pickedImage as File,
      json['id'],
    );
    Staff _staff = Staff.fromJson(json);

    await showDialog(
      context: context,
      builder: (context) => FutureProgressDialog(
        FirestoreService().setStaff(_staff),
        message: Text("Uploading profile..."),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
    );

    Get.snackbar(
      'Save Success',
      'Profile has been successfully uploaded!',
      backgroundColor: Colors.greenAccent,
      colorText: Colors.white,
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
    );

    return json['profile_url'];
  }

  Future _saveQRCode() async {
    await Permission.storage.request();
    Uint8List data = await showDialog(
      context: context,
      builder: (context) => FutureProgressDialog(
        _generateQRCode(),
        message: Text("Generating qrcode..."),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
    );

    var success = await ImageGallerySaver.saveImage(
      data,
      name: "${admin.lastName}_${admin.id}",
    );

    if (success != null)
      Get.snackbar(
        'Save Success',
        'QRCode has been generated and saved to your gallery!',
        backgroundColor: Colors.greenAccent,
        colorText: Colors.white,
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.BOTTOM,
      );
    else
      Get.snackbar(
        'Save Failed',
        'Failed to generate and save qrcode!',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.BOTTOM,
      );
  }

  Future _generateQRCode() async {
    Uint8List data = await QRScanner.generateBarCode(admin.id);
    return data;
  }

  Widget _buildTextField(TextEditingController? controller, String label,
      String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          suffixIcon: Icon(
            icon,
            color: Colors.black54,
          ),
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
