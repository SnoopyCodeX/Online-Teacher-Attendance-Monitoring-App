import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/absent.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/late.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/staff.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> uploadImage(File file, String id) async {
    Reference ref = _storage.ref().child("/images/users/$id");
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot =
        await uploadTask.whenComplete(() => print("Upload: DONE!"));
    return await snapshot.ref.getDownloadURL();
  }

  Future<double> getNumberOfStaffs() async {
    var query = _db.collection('staffs');
    var snapshot = await query.get();
    var count = snapshot.size;

    /*.orderBy('id', descending: false);
    var lastDocId = '';
    var count = 0;

    while (true) {
      var offsetQuery = lastDocId != '' ? query.startAfter([lastDocId]) : query;
      var snapshot = await offsetQuery.limit(2).get();
      var size = snapshot.size;
      if (size == 0) break;
      count += size;
      lastDocId = snapshot.docs[size - 1].id;

      if (size == 1 || size == 0) break;
    }

    print("Staffs: $count");
    */
    return double.parse("$count");
  }

  Future<int> getNumberOfAbsences() async {
    var query = _db.collection('absences');
    var snapshot = await query.get();
    var count = snapshot.size;

    /*.orderBy('id', descending: false);
    var lastDocId = '';
    var count = 0;

    while (true) {
      var offsetQuery = lastDocId != '' ? query.startAfter([lastDocId]) : query;
      var snapshot = await offsetQuery.limit(2).get();
      var size = snapshot.size;
      if (size == 0) break;
      count += size;
      lastDocId = snapshot.docs[size - 1].id;

      if (size == 1 || size == 0) break;
    }

    print("Absences: $count");
    */

    return count;
  }

  Future<int> getNumberOfLates() async {
    var query = _db.collection('lates');
    var snapshot = await query.get();
    var count = snapshot.size;

    /*.orderBy('id', descending: false);
    var lastDocId = '';
    var count = 0;

    while (true) {
      var offsetQuery = lastDocId != '' ? query.startAfter([lastDocId]) : query;
      var snapshot = await offsetQuery.limit(2).get();
      var size = snapshot.size;
      if (size == 0) break;
      count += size;
      lastDocId = snapshot.docs[size - 1].id;

      if (size == 1 || size == 0) break;
    }

    print("Lates: $count");
    */

    return count;
  }

  Future<List<Staff>> getStaffsFuture() {
    return _db.collection('staffs').get().then((snapshot) =>
        snapshot.docs.map((doc) => Staff.fromJson(doc.data())).toList());
  }

  Stream<List<Staff>> getStaffsStream() {
    return _db.collection('staffs').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Staff.fromJson(doc.data())).toList());
  }

  Future<List<Staff>> getStaff(String key, dynamic value) {
    return (_db.collection('staffs').where(key, isEqualTo: value).get().then(
        (snapshot) =>
            snapshot.docs.map((doc) => Staff.fromJson(doc.data())).toList()));
  }

  Future<void> setStaff(Staff staff) async {
    Map<String, dynamic> json = staff.toMap();
    int length = (await getStaff('email_address', json['id'])).length;

    if (length <= 0)
      json['qrcode'] = (DBCrypt().hashpw(json['id'], DBCrypt().gensalt()));

    return _db
        .collection('staffs')
        .doc(json['id'])
        .set(json, SetOptions(merge: true));
  }

  Future<void> removeStaff(String id) async {
    await _storage.ref().child('/images/users/$id').delete();
    return _db.collection('staffs').doc(id).delete();
  }

  Stream<List<Absent>> getAbsents() {
    return _db.collection('absences').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Absent.fromJson(doc.data())).toList());
  }

  Future<List<Absent>> getAbsent(String key, String value) {
    return (_db.collection('absences').where(key, isEqualTo: value).get().then(
        (snapshot) =>
            snapshot.docs.map((doc) => Absent.fromJson(doc.data())).toList()));
  }

  Future<void> putAbsent(Absent absent) {
    Map<String, dynamic> json = absent.toMap();
    json['id'] = Uuid().v4();
    return _db.collection('absences').doc(json['id']).set(json);
  }

  Future<void> removeAbsent(String id) {
    return _db.collection('absences').doc(id).delete();
  }

  Stream<List<Late>> getLates() {
    return _db.collection('lates').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Late.fromJson(doc.data())).toList());
  }

  Future<List<Late>> getLate(String key, String value) {
    return (_db.collection('lates').where(key, isEqualTo: value).get().then(
        (snapshot) =>
            snapshot.docs.map((doc) => Late.fromJson(doc.data())).toList()));
  }

  Future<void> putLate(Late late) {
    Map<String, dynamic> json = late.toMap();
    json['id'] = Uuid().v4();
    return _db.collection('lates').doc(json['id']).set(json);
  }

  Future<void> removelate(String id) {
    return _db.collection('lates').doc(id).delete();
  }
}
