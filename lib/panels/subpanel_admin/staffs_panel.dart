import 'dart:async';

import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/staff.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/panels/profile_panel.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/services/firestore_service.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/widget/search_widget.dart';

class AdminStaffsPanel extends StatefulWidget {
  final Staff admin;

  AdminStaffsPanel({required this.admin});

  @override
  _AdminStaffsPanelState createState() => _AdminStaffsPanelState(this.admin);
}

class _AdminStaffsPanelState extends State<AdminStaffsPanel>
    with SingleTickerProviderStateMixin {
  final Staff admin;

  _AdminStaffsPanelState(this.admin);

  List<Staff> staffs = [];
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = new ScrollController();
    _loadStaffs();
  }

  @override
  void dispose() {
    super.dispose();

    _scrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("DATA: ${staffs.length}");
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10,
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              SearchWidget(
                text: 'Seacrch staff',
                onChanged: (query) => _searchStaff(query),
                hintText: 'Search staff',
              ),
              Expanded(
                child: LiquidPullToRefresh(
                  showChildOpacityTransition: false,
                  onRefresh: _onRefresh,
                  child: this.staffs.isNotEmpty
                      ? ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          itemCount: this.staffs.length,
                          itemBuilder: (context, index) =>
                              _createListItem(index),
                        )
                      : SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          child: Center(
                            child: Text('No data found'),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    print("Refresh");
    await _loadStaffs();
  }

  Future<void> _loadStaffs() async {
    List<Staff> data = await FirestoreService().getStaffsFuture();
    List<Staff> filtered = [];

    for (Staff staff in data)
      if (staff.id == admin.id)
        continue;
      else
        filtered.add(staff);

    setState(() {
      this.staffs = filtered;
    });
  }

  Future<void> _showOptions(Staff staff) async {
    await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: null,
        content: new Text('Do you want to delete this account?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text(
              'Cancel',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: new Text("Are you sure?"),
                  content: new Text(
                      "Deleting this account from the system will not be reverted"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop(false);

                        await showDialog(
                          context: context,
                          builder: (context) => FutureProgressDialog(
                            FirestoreService().removeStaff(staff.id),
                            message: Text("Deleting account..."),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                        );

                        Get.snackbar(
                          'Delete Successful',
                          'Staff\'s account was successfully deleted from the system!',
                          backgroundColor: Colors.greenAccent,
                          colorText: Colors.white,
                          snackStyle: SnackStyle.FLOATING,
                          snackPosition: SnackPosition.BOTTOM,
                        );

                        await _loadStaffs();
                      },
                      child: Text(
                        'Yes delete',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.orangeAccent,
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
            child: new Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createListItem(index) {
    List<Staff> data = staffs;
    Staff staff = data[index];
    print("Index: $index");

    return ListTile(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfilePanel(staff: staff, edit: true))),
      onLongPress: () => _showOptions(staff),
      leading: staff.profileUrl.isNotEmpty
          ? CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(staff.profileUrl),
            )
          : CircleAvatar(),
      title: Text(
        "${staff.lastName}, ${staff.firstName} ${staff.middleName.length > 1 ? staff.middleName.substring(0, 1) : staff.middleName}",
        style: GoogleFonts.poppins(color: Colors.black87, fontSize: 18),
      ),
      subtitle: Text(
        "Status: ${staff.isActive ? 'Active' : 'Inactive'}",
        style: GoogleFonts.poppins(color: Colors.black87, fontSize: 12),
      ),
    );
  }

  Future<void> _searchStaff(String query) async {
    if (query.isNotEmpty) {
      print(query);
      List<Staff> matches = [];

      for (int i = 0; i < this.staffs.length; i++) {
        Staff staff = this.staffs[i];
        String _match =
            "${staff.lastName}, ${staff.firstName} ${staff.middleName}";

        if (_match.toLowerCase().contains(query.toLowerCase()))
          matches.add(staff);
      }

      setState(() {
        this.staffs = matches;
      });
    } else
      _loadStaffs();
  }
}
