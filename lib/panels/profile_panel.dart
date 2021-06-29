import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/staff.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/services/firestore_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as QRScanner;
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:uuid/uuid.dart';

class ProfilePanel extends StatefulWidget {
  final Staff staff;
  final bool edit;
  final bool teacher;

  ProfilePanel({required this.staff, required this.edit, this.teacher = false});

  @override
  _ProfilePanelState createState() =>
      _ProfilePanelState(staff: staff, edit: edit, teacher: teacher);
}

class _ProfilePanelState extends State<ProfilePanel>
    with SingleTickerProviderStateMixin {
  ProgressDialog? pd;
  TextEditingController? _firstName,
      _middleName,
      _lastName,
      _email,
      _number,
      _address;

  File? pickedImage;
  bool changedPhoto = false;

  final Staff staff;
  final bool edit;
  final bool teacher;

  _ProfilePanelState(
      {required this.staff, required this.edit, this.teacher = false});

  @override
  void initState() {
    super.initState();

    this.pd = ProgressDialog(context: context);
    this._firstName = new TextEditingController(text: staff.firstName);
    this._middleName = new TextEditingController(text: staff.middleName);
    this._lastName = new TextEditingController(text: staff.lastName);
    this._email = new TextEditingController(text: staff.emailAddress);
    this._number = new TextEditingController(text: staff.contactNumber);
    this._address = new TextEditingController(text: staff.homeAddress);
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
    return Scaffold(
      appBar: !this.teacher
          ? AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(true),
                icon: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: Colors.black87,
                ),
              ),
            )
          : null,
      body: Container(
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
                edit ? "Edit Profile" : "Add Profile",
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
                              : NetworkImage(staff.profileUrl.isNotEmpty
                                  ? staff.profileUrl
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
                'Staff\'s first name',
                Icons.person_outline,
              ),
              _buildTextField(_middleName, 'Middle name',
                  'Staff\'s middle name', Icons.person_outline),
              _buildTextField(
                _lastName,
                'Last name',
                'Staff\'s last name',
                Icons.person_outline,
              ),
              _buildTextField(
                _email,
                'Email address',
                'Staff\'s email address',
                Icons.email_outlined,
              ),
              _buildTextField(_number, 'Contact number',
                  'Staff\'s contact number', Icons.phone_android_outlined),
              _buildTextField(_address, 'Home adddress',
                  'Staff\'s home address', Icons.location_city_outlined),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: Colors.deepOrangeAccent,
                        fontSize: 14,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ),
                  edit
                      ? OutlinedButton(
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
                        )
                      : SizedBox(),
                  OutlinedButton(
                    onPressed: () => edit ? _saveProfile() : _addProfile(),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Text(
                      edit ? 'Save' : 'Add',
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
    );
  }

  Future _saveProfile() async {
    if (_firstName!.text.isEmpty ||
        _lastName!.text.isEmpty ||
        _email!.text.isEmpty ||
        !_email!.text.isEmail ||
        _address!.text.isEmpty ||
        _number!.text.isEmpty ||
        !_number!.text.isPhoneNumber) {
      Get.snackbar(
        'Save Failed',
        'Please properly fill up all the required fields!',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Map<String, dynamic> json = this.staff.toMap();
    if (changedPhoto)
      json['profile_url'] = await _uploadImage(Staff.fromJson(json));

    json['first_name'] = _firstName!.text;
    json['middle_name'] = _middleName!.text;
    json['last_name'] = _lastName!.text;
    json['email_address'] = _email!.text;
    json['home_address'] = _address!.text;
    json['contact_number'] = _number!.text;

    Staff _staff = Staff.fromJson(json);

    pd!.show(
      max: 100,
      msg: 'Saving profile...',
      progressType: ProgressType.valuable,
    );
    await FirestoreService().setStaff(_staff);
    pd!.close();
    // showDialog(
    //   context: context,
    //   builder: (context) => FutureProgressDialog(
    //     FirestoreService().setStaff(_staff),
    //     message: Text("Saving profile..."),
    //     decoration: BoxDecoration(
    //       color: Colors.white,
    //       borderRadius: BorderRadius.all(
    //         Radius.circular(10),
    //       ),
    //     ),
    //   ),
    // );

    Get.snackbar(
      'Save Success',
      'Profile has been successfully updated!',
      backgroundColor: Colors.greenAccent,
      colorText: Colors.white,
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
    );

    Navigator.of(context).pop(true);
  }

  Future _addProfile() async {
    if (_firstName!.text.isEmpty ||
        _lastName!.text.isEmpty ||
        _email!.text.isEmpty ||
        !_email!.text.isEmail ||
        _address!.text.isEmpty ||
        _number!.text.isEmpty ||
        !_number!.text.isPhoneNumber) {
      Get.snackbar(
        'Save Failed',
        'Please properly fill up all the required fields!',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    List<Staff> data =
        await FirestoreService().getStaff('email_address', _email!.text);
    Staff staff = Staff(
      firstName: _firstName!.text,
      middleName: _middleName!.text,
      lastName: _lastName!.text,
      emailAddress: _email!.text,
      contactNumber: _number!.text,
      homeAddress: _address!.text,
      id: Uuid().v4(),
      qrCode: '',
      lastIn: '',
      lastOut: '',
      profileUrl: '',
      isActive: false,
      systemRole: 0,
    );

    if (data.length > 0) {
      Get.snackbar(
        'Create failed',
        'Account already exists in the database.',
        backgroundColor: Colors.deepOrangeAccent,
        colorText: Colors.white,
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.BOTTOM,
      );
      Navigator.of(context).pop(true);
      return;
    }

    pd!.show(
      max: 100,
      msg: 'Creating profile...',
      progressType: ProgressType.valuable,
    );
    await FirestoreService().setStaff(staff);
    pd!.close();

    Get.snackbar(
      'Save Success',
      'Profile has been successfully created!',
      backgroundColor: Colors.greenAccent,
      colorText: Colors.white,
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
    );

    await _uploadImage(staff);

    Get.back(closeOverlays: true);
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

    pd!.show(
      max: 100,
      msg: 'Uploading profile...',
      progressType: ProgressType.valuable,
    );
    await FirestoreService().setStaff(_staff);
    pd!.close();

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

    pd!.show(
      max: 100,
      msg: 'Generating qrcode...',
      progressType: ProgressType.valuable,
    );
    Uint8List data = await _generateQRCode();
    pd!.close();

    var success = await ImageGallerySaver.saveImage(
      data,
      name: "${staff.lastName}_${staff.id}",
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
    Uint8List data = await QRScanner.generateBarCode(staff.id);
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
