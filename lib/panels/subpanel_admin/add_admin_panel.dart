import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/staff.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/services/firestore_service.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/widget/search_widget.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class AddAdminPanel extends StatefulWidget {
  final Staff admin;

  AddAdminPanel({required this.admin});

  @override
  _AddAdminPanelState createState() => _AddAdminPanelState(admin);
}

class _AddAdminPanelState extends State<AddAdminPanel>
    with SingleTickerProviderStateMixin {
  final Staff admin;
  ScrollController? _scrollController;
  List<Staff> admins = [];

  _AddAdminPanelState(this.admin);

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Select Admin',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 23,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(true),
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
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
                child: this.admins.isNotEmpty
                    ? ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: _scrollController,
                        itemCount: this.admins.length,
                        itemBuilder: (context, index) => _createListItem(index),
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
    );
  }

  Future _onRefresh() async {
    await _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    List<Staff> data = await FirestoreService().getStaff('system_role', 0);
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
        content: new Text('Do you want to promote this account?'),
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
                      "Do you really want to promote this account? You can demote this from admin again anytime."),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop(false);

                        Map<String, dynamic> json = admin.toMap();
                        json['system_role'] = 1;

                        ProgressDialog pd = ProgressDialog(context: context);
                        pd.show(
                            max: 100,
                            msg: 'Promoting account...',
                            progressType: ProgressType.valuable);
                        await FirestoreService().setStaff(Staff.fromJson(json));
                        pd.close();
                        // showDialog(
                        //   context: context,
                        //   builder: (context) => FutureProgressDialog(
                        //     FirestoreService().setStaff(Staff.fromJson(json)),
                        //     message: Text("Promoting account..."),
                        //     decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.all(
                        //         Radius.circular(10),
                        //       ),
                        //     ),
                        //   ),
                        // );

                        Get.snackbar(
                          'Promoted Successfully',
                          'Staff\'s account was successfully promotoed as an admin of the system!',
                          backgroundColor: Colors.greenAccent,
                          colorText: Colors.white,
                          snackStyle: SnackStyle.FLOATING,
                          snackPosition: SnackPosition.BOTTOM,
                        );

                        await _loadAdmins();
                        Get.back(closeOverlays: true);
                      },
                      child: Text(
                        'Yes promote',
                        style: TextStyle(
                          color: Colors.green.shade900,
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
              'Promote',
              style: TextStyle(
                color: Colors.green.shade900,
              ),
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
      onTap: () => _showOptions(admin),
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

  Future<void> _searchStaff(String query) async {
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
