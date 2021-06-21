import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/staff.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/services/firestore_service.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/widget/search_widget.dart';

class AdminListPanel extends StatefulWidget {
  final Staff admin;

  AdminListPanel({required this.admin});

  @override
  _AdminListPanelState createState() => _AdminListPanelState(admin);
}

class _AdminListPanelState extends State<AdminListPanel>
    with SingleTickerProviderStateMixin {
  final Staff admin;
  ScrollController? _scrollController;
  List<Staff> admins = [];

  _AdminListPanelState(this.admin);

  @override
  void initState() {
    super.initState();

    _scrollController = new ScrollController();
    _loadAdmins();
  }

  @override
  void dispose() {
    super.dispose();

    _scrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                text: 'Seacrch admin',
                onChanged: (query) => _searchAdmin(query),
                hintText: 'Search admin',
              ),
              Expanded(
                child: LiquidPullToRefresh(
                  showChildOpacityTransition: false,
                  onRefresh: _onRefresh,
                  child: this.admins.isNotEmpty
                      ? ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          itemCount: this.admins.length,
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

  Future _onRefresh() async {
    await _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    List<Staff> data = await FirestoreService().getStaff('system_role', 1);
    List<Staff> filtered = [];

    for (Staff staff in data)
      if (staff.id == admin.id)
        continue;
      else
        filtered.add(staff);

    setState(() {
      this.admins = filtered;
    });
  }

  Future<void> _showOptions(Staff admin) async {
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
                            FirestoreService().removeStaff(admin.id),
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

                        await _loadAdmins();
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
    List<Staff> data = admins;
    Staff admin = data[index];
    print("Index: $index");

    return ListTile(
      onLongPress: () => _showOptions(admin),
      leading: admin.profileUrl.isNotEmpty
          ? CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(admin.profileUrl),
            )
          : CircleAvatar(),
      title: Text(
        "${admin.lastName}, ${admin.firstName} ${admin.middleName.length > 1 ? admin.middleName.substring(0, 1) : admin.middleName}",
        style: GoogleFonts.poppins(color: Colors.black87, fontSize: 18),
      ),
      subtitle: Text(
        "Status: ${admin.isActive ? 'Active' : 'Inactive'}",
        style: GoogleFonts.poppins(color: Colors.black87, fontSize: 12),
      ),
    );
  }

  Future<void> _searchAdmin(String query) async {
    if (query.isNotEmpty) {
      print(query);
      List<Staff> matches = [];

      for (int i = 0; i < this.admins.length; i++) {
        Staff admin = this.admins[i];
        String _match =
            "${admin.lastName}, ${admin.firstName} ${admin.middleName}";

        if (_match.toLowerCase().contains(query.toLowerCase()))
          matches.add(admin);
      }

      setState(() {
        this.admins = matches;
      });
    } else
      _loadAdmins();
  }
}
