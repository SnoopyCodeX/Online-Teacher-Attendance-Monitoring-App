import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_cache/flutter_cache.dart' as Cache;
import 'package:online_teacher_staff_attendance_monitoring_app/models/staff.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/login_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/profile_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/subpanel_admin/admins_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/subpanel_admin/attendance_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/subpanel_admin/dashboard_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/subpanel_admin/profile_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/subpanel_admin/staffs_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/services/firestore_service.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/utils/utils.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/utils/constants.dart';

class AdminPanel extends StatefulWidget {
  final Staff admin;

  AdminPanel({required this.admin});

  @override
  _AdminPanelState createState() => _AdminPanelState(admin: admin);
}

class _AdminPanelState extends State<AdminPanel>
    with SingleTickerProviderStateMixin {
  final Staff admin;

  _AdminPanelState({required this.admin});

  Duration duration = Duration(milliseconds: 150);
  AnimationController? _controller;
  Animation<double>? _scaleAnimation;
  Animation<double>? _menuScaleAnimation;
  Animation<Offset>? _slideAnimation;
  double screenWidth = 0, screenHeight = 0;
  int activeMenu = 0;
  bool isCollapsed = true;
  Uint8List? imageUrl;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: duration);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.8)
        .animate(_controller as AnimationController);
    _menuScaleAnimation = Tween<double>(begin: 0.5, end: 1)
        .animate(_controller as AnimationController);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller as AnimationController);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = AdminDashboardPanel();
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;

    switch (activeMenu) {
      case 0:
        screen = AdminDashboardPanel();
        break;

      case 1:
        screen = AdminStaffsPanel(
          admin: this.admin,
        );
        break;

      case 2:
        screen = AdminListPanel(
          admin: this.admin,
        );
        break;

      case 3:
        screen = AdminAttendanceListPanel();
        break;

      case 4:
        screen = AdminProfilePanel(
          admin: this.admin,
        );
        break;

      default:
        screen = AdminDashboardPanel();
    }

    return WillPopScope(
      onWillPop: () async {
        if (!isCollapsed) {
          setState(() {
            if (isCollapsed)
              _controller?.forward();
            else
              _controller?.reverse();

            isCollapsed = !isCollapsed;
          });

          return false;
        }
        return (await showDialog(
              context: context,
              builder: (context) => new AlertDialog(
                title: new Text('Are you sure?'),
                content: new Text('Do you want to exit this app'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: new Text('Yes'),
                  ),
                ],
              ),
            )) ??
            false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: primaryColor,
          floatingActionButton:
              ((activeMenu == 1 || activeMenu == 2) && isCollapsed)
                  ? FloatingActionButton(
                      onPressed: () => (activeMenu == 1)
                          ? Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfilePanel(
                                  staff: Staff.create(),
                                  edit: false,
                                ),
                              ),
                            )
                          : Get.snackbar(
                              'No Ready',
                              'This function is not yet implemented!',
                              backgroundColor: Colors.deepOrangeAccent,
                              colorText: Colors.white,
                              snackStyle: SnackStyle.FLOATING,
                              snackPosition: SnackPosition.BOTTOM,
                            ),
                      child: Icon(
                        Icons.add_outlined,
                        color: Colors.white,
                      ),
                    )
                  : null,
          body: Stack(
            children: [
              SlideTransition(
                position: _slideAnimation as Animation<Offset>,
                child: ScaleTransition(
                  scale: _menuScaleAnimation as Animation<double>,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 40,
                        bottom: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Row(
                            children: [
                              admin.profileUrl.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 25,
                                      backgroundImage:
                                          NetworkImage(admin.profileUrl),
                                    )
                                  : CircleAvatar(
                                      radius: 25,
                                    ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "${admin.lastName}, ${admin.firstName}",
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Role: Administrator',
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                createMenuItem(
                                  Icons.dashboard_outlined,
                                  'Dashboard',
                                  () {
                                    setState(() {
                                      if (isCollapsed)
                                        _controller?.forward();
                                      else
                                        _controller?.reverse();
                                      isCollapsed = !isCollapsed;
                                      activeMenu = 0;
                                    });
                                  },
                                  activeMenu == 0 ? true : false,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                createMenuItem(
                                  Icons.account_box_outlined,
                                  'Staffs',
                                  () {
                                    setState(() {
                                      if (isCollapsed)
                                        _controller?.forward();
                                      else
                                        _controller?.reverse();
                                      isCollapsed = !isCollapsed;
                                      activeMenu = 1;
                                    });
                                  },
                                  activeMenu == 1 ? true : false,
                                ),
                                createMenuItem(
                                  FontAwesomeIcons.modx,
                                  'Admins',
                                  () {
                                    setState(() {
                                      if (isCollapsed)
                                        _controller?.forward();
                                      else
                                        _controller?.reverse();
                                      isCollapsed = !isCollapsed;
                                      activeMenu = 2;
                                    });
                                  },
                                  activeMenu == 2 ? true : false,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                createMenuItem(
                                  Icons.calendar_today_outlined,
                                  'Attendance',
                                  () {
                                    setState(() {
                                      if (isCollapsed)
                                        _controller?.forward();
                                      else
                                        _controller?.reverse();
                                      isCollapsed = !isCollapsed;
                                      activeMenu = 3;
                                    });
                                  },
                                  activeMenu == 3 ? true : false,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                createMenuItem(
                                  Icons.person_outlined,
                                  'Profile',
                                  () {
                                    setState(() {
                                      if (isCollapsed)
                                        _controller?.forward();
                                      else
                                        _controller?.reverse();
                                      isCollapsed = !isCollapsed;
                                      activeMenu = 4;
                                    });
                                  },
                                  activeMenu == 4 ? true : false,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.copyright_outlined,
                                color: Colors.white54,
                                size: 18,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text('SnoopyCodeX',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white54)),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                  width: 1, height: 20, color: Colors.white54),
                              SizedBox(
                                width: 10,
                              ),
                              Text('2021 - 2022',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white54)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                top: 0,
                bottom: 0,
                left: isCollapsed ? 0 : 0.6 * screenWidth,
                right: isCollapsed ? 0 : -0.4 * screenWidth,
                duration: duration,
                child: ScaleTransition(
                  scale: _scaleAnimation as Animation<double>,
                  child: Material(
                    borderRadius:
                        BorderRadius.all(Radius.circular(isCollapsed ? 0 : 40)),
                    elevation: 8,
                    color: Colors.white,
                    child: Container(
                      decoration: isCollapsed
                          ? BoxDecoration()
                          : BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black87,
                                  offset: Offset(4, 4),
                                  blurRadius: 15,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color: Colors.black87,
                                  offset: Offset(-4, -4),
                                  blurRadius: 15,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                              left: 5,
                              right: 5,
                              top: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (isCollapsed)
                                        _controller?.forward();
                                      else
                                        _controller?.reverse();

                                      isCollapsed = !isCollapsed;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.menu_outlined,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Admin Panel',
                                  style: GoogleFonts.poppins(
                                      color: Colors.black, fontSize: 22),
                                ),
                                IconButton(
                                  onPressed: () => _logout(),
                                  icon: Icon(
                                    Icons.logout_outlined,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          screen
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /* REMOVED SWIPE TO AVOID CONFLICT
              GestureDetector(
                onHorizontalDragUpdate: (event) {
                  if (event.delta.dx > 0.4)
                    setState(() {
                      if (isCollapsed)
                        _controller?.reverse();
                      else
                        _controller?.forward();
                      isCollapsed = false;
                    });
                  else
                    setState(() {
                      if (isCollapsed)
                        _controller?.reverse();
                      else
                        _controller?.forward();
                      isCollapsed = true;
                    });
                },
              )
              */
            ],
          ),
        ),
      ),
    );
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

              Map<String, dynamic> json = admin.toMap();
              json['is_active'] = false;

              Staff _admin = Staff.fromJson(json);

              await showDialog(
                context: context,
                builder: (context) => FutureProgressDialog(
                  FirestoreService().setStaff(_admin),
                  message: Text("Saving profile..."),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
              );

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
}
