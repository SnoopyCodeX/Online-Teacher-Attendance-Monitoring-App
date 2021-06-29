import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/absent.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/late.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/staff.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/login_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/profile_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/services/firestore_service.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

class TeacherHomePanel extends StatefulWidget {
  final Staff teacher;

  TeacherHomePanel({required this.teacher});

  @override
  _TeacherHomePanelState createState() => _TeacherHomePanelState(this.teacher);
}

class _TeacherHomePanelState extends State<TeacherHomePanel>
    with SingleTickerProviderStateMixin {
  final Staff teacherAcc;

  _TeacherHomePanelState(this.teacherAcc);

  Staff? teacher;
  String _message = '';
  // CalendarFormat _format = CalendarFormat.month;
  // DateTime _selectedDay = DateTime.now();
  bool checkedIn = false;
  int activeIndex = 1;

  @override
  void initState() {
    super.initState();

    teacher = teacherAcc;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _message = !teacher!.isActive
        ? 'Your last check-in was:  ${Jiffy(teacher!.lastOut, 'yyyy-MM-dd hh:mm a').fromNow()}'
        : 'Checked in: ${Jiffy(teacher!.lastOut, 'yyyy-MM-dd hh:mm a').format('EEEE, MM dd, yyyy hh:mm a')}';

    return Scaffold(
      bottomNavigationBar: ConvexAppBar(
        initialActiveIndex: activeIndex,
        backgroundColor: Colors.pinkAccent.shade400,
        items: <TabItem>[
          TabItem(icon: Icons.person, title: 'Profile'),
          TabItem(icon: Icons.home, title: 'Home'),
          // TabItem(icon: Icons.calendar_today, title: 'Attendance'),
        ],
        onTap: (index) {
          setState(() {
            activeIndex = index;
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent.shade400,
        centerTitle: true,
        title: Text(
          'Attendance',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => _logout(),
            icon: Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 26,
            ),
          )
        ],
      ),
      body: Container(
        alignment: activeIndex == 2 ? Alignment.topLeft : Alignment.center,
        child: _getPage(),
      ),
    );
  }

  Widget _getPage() {
    Widget _page = Container();

    switch (activeIndex) {
      case 0:
        return ProfilePanel(staff: teacher as Staff, edit: true, teacher: true);

      case 1:
        _page = SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    padding: EdgeInsets.all(10),
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
                        image: NetworkImage(teacher!.profileUrl),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  '${teacher!.firstName} ${teacher!.middleName.substring(0, 1)}. ${teacher!.lastName}',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Center(
                child: Text(
                  _message,
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              ElevatedButton(
                onPressed: () => checkedIn ? _checkOut() : _checkIn(),
                style: ElevatedButton.styleFrom(
                  primary: Colors.pinkAccent.shade400,
                  fixedSize: Size(
                    200,
                    50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                ),
                child: Text(
                  checkedIn ? 'CHECK-OUT' : 'CHECK-IN',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () => _absent(),
                style: ElevatedButton.styleFrom(
                  primary: Colors.pinkAccent.shade400,
                  fixedSize: Size(
                    200,
                    50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                ),
                child: Text(
                  'ABSENT',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () => _late(),
                style: ElevatedButton.styleFrom(
                  primary: Colors.pinkAccent.shade400,
                  fixedSize: Size(
                    200,
                    50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                ),
                child: Text(
                  'LATE',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        );
        break;

      // case 2:
      //   _page = SingleChildScrollView(
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: <Widget>[
      //         Card(
      //           clipBehavior: Clip.antiAlias,
      //           margin: EdgeInsets.all(8),
      //           child: TableCalendar(
      //             focusedDay: _selectedDay,
      //             firstDay: DateTime(1990),
      //             lastDay: DateTime(3000),
      //             calendarFormat: _format,
      //             weekendDays: [6, 7],
      //             selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      //             onFormatChanged: (format) {
      //               setState(() {
      //                 _format = format;
      //               });
      //             },
      //             onDaySelected: (selectedDay, focusedDay) {
      //               setState(() {
      //                 _selectedDay = selectedDay;
      //               });
      //             },
      //             headerStyle: HeaderStyle(
      //               decoration:
      //                   BoxDecoration(color: Colors.pinkAccent.shade400),
      //               headerMargin: EdgeInsets.only(bottom: 8),
      //               titleTextStyle:
      //                   GoogleFonts.poppins(color: Colors.white, fontSize: 17),
      //               formatButtonDecoration: BoxDecoration(
      //                 border: Border.all(color: Colors.white, width: 1.4),
      //                 borderRadius: BorderRadius.all(Radius.circular(12)),
      //               ),
      //               formatButtonTextStyle:
      //                   GoogleFonts.poppins(color: Colors.white),
      //               leftChevronIcon:
      //                   Icon(Icons.chevron_left, color: Colors.white),
      //               rightChevronIcon:
      //                   Icon(Icons.chevron_right, color: Colors.white),
      //             ),
      //             calendarStyle: CalendarStyle(
      //               weekendTextStyle:
      //                   TextStyle(color: Colors.pinkAccent.shade400),
      //               todayDecoration: BoxDecoration(
      //                 border: Border.all(
      //                     color: Colors.pinkAccent.shade400, width: 1.8),
      //                 shape: BoxShape.circle,
      //               ),
      //               todayTextStyle: TextStyle(color: Colors.black),
      //               selectedDecoration: BoxDecoration(
      //                 color: Colors.pinkAccent.shade400,
      //                 shape: BoxShape.circle,
      //               ),
      //             ),
      //           ),
      //         ),
      //         SizedBox(
      //           height: 10,
      //         ),
      //         Container(
      //           padding: EdgeInsets.all(8),
      //           child: Column(
      //             children: <Widget>[
      //               Row(
      //                 children: <Widget>[
      //                   Text('')
      //                 ],
      //               ),
      //             ],
      //           ),
      //         )
      //       ],
      //     ),
      //   );
      //   break;

      default:
        _page = Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 80, bottom: 5),
              child: Center(
                child: Container(
                  width: 140,
                  height: 140,
                  padding: EdgeInsets.all(10),
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
                      image: NetworkImage(teacher!.profileUrl),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                '${teacher!.firstName} ${teacher!.middleName.substring(0, 1)}. ${teacher!.lastName}',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Center(
              child: Text(
                _message,
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () => checkedIn ? _checkOut() : _checkIn(),
              style: ElevatedButton.styleFrom(
                primary: Colors.pinkAccent.shade400,
                fixedSize: Size(
                  200,
                  50,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
              ),
              child: Text(
                checkedIn ? 'CHECK-OUT' : 'CHECK-IN',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () => _absent(),
              style: ElevatedButton.styleFrom(
                primary: Colors.pinkAccent.shade400,
                fixedSize: Size(
                  200,
                  50,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
              ),
              child: Text(
                'ABSENT',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () => _late(),
              style: ElevatedButton.styleFrom(
                primary: Colors.pinkAccent.shade400,
                fixedSize: Size(
                  200,
                  50,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
              ),
              child: Text(
                'LATE',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        );
    }

    return _page;
  }

  Future _logout() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log out'),
        content: Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(false);

              Cache.clear();
              Get.offAll(() => LoginPanel());
            },
            child: Text(
              'Yes',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'No',
              style: TextStyle(color: Colors.deepOrangeAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future _checkIn() async {
    Map<String, dynamic> json = teacher!.toMap();
    String _timeIn = Jiffy(DateTime.now()).format('yyyy-MM-dd hh:mm a');
    json['is_active'] = true;
    json['last_in'] = _timeIn;

    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 100,
      msg: 'Checking in...',
      progressType: ProgressType.valuable,
    );
    await FirestoreService().setStaff(Staff.fromJson(json));
    await Cache.write('data', json);
    pd.close();

    setState(() {
      _message =
          'Checked in: ${Jiffy(_timeIn, 'yyyy-MM-dd hh:mm a').format('EEEE, MM dd, yyyy hh:mm a')}';
      checkedIn = true;
      teacher = Staff.fromJson(json);
    });
  }

  Future _checkOut() async {
    Map<String, dynamic> json = teacher!.toMap();
    String _timeOut = Jiffy(DateTime.now()).format('yyyy-MM-dd hh:mm a');
    json['is_active'] = false;
    json['last_out'] = _timeOut;

    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 100,
      msg: 'Checking out...',
      progressType: ProgressType.valuable,
    );
    await FirestoreService().setStaff(Staff.fromJson(json));
    await Cache.write('data', json);
    pd.close();

    setState(() {
      _message =
          'Checked in: ${Jiffy(_timeOut, 'yyyy-MM-dd hh:mm a').format('EEEE, MM dd, yyyy hh:mm a')}';
      checkedIn = false;
      teacher = Staff.fromJson(json);
    });
  }

  Future _absent() async {
    Absent _absent = Absent(
      absentDate: Jiffy(DateTime.now()).format('yyyy-MM-dd'),
      firstName: teacher!.firstName,
      middleName: teacher!.middleName,
      lastName: teacher!.lastName,
      profileUrl: teacher!.profileUrl,
      staffId: teacher!.id,
      id: Uuid().v4(),
    );

    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 100,
      msg: 'Updating status...',
      progressType: ProgressType.valuable,
    );
    await FirestoreService().putAbsent(_absent);
    pd.close();

    setState(() {
      _message = 'You have marked yourself as absent.';
    });

    Get.snackbar(
      'Status Updated',
      'You have marked yourself as absent successfully!',
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.greenAccent,
      colorText: Colors.white,
    );
  }

  Future _late() async {
    Late _late = Late(
      lateDate: Jiffy(DateTime.now()).format('yyyy-MM-dd'),
      firstName: teacher!.firstName,
      middleName: teacher!.middleName,
      lastName: teacher!.lastName,
      profileUrl: teacher!.profileUrl,
      staffId: teacher!.id,
      id: Uuid().v4(),
    );

    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 100,
      msg: 'Updating status...',
      progressType: ProgressType.valuable,
    );
    await FirestoreService().putLate(_late);
    pd.close();

    setState(() {
      _message = 'You have marked yourself as late.';
    });

    Get.snackbar(
      'Status Updated',
      'You have marked yourself as late successfully!',
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.greenAccent,
      colorText: Colors.white,
    );
  }
}
