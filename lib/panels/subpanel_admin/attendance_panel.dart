import 'package:expansion_widget/expansion_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/absent.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/late.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/services/firestore_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math' as math;

class AdminAttendanceListPanel extends StatefulWidget {
  @override
  _AdminAttendanceListPanelState createState() =>
      _AdminAttendanceListPanelState();
}

class _AdminAttendanceListPanelState extends State<AdminAttendanceListPanel> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();

  int page = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: 10,
        ),
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            ExpansionWidget(
              initiallyExpanded: false,
              titleBuilder: (double animationValue, double easeInValue,
                      bool isExpanded, toggleFunction) =>
                  InkWell(
                onTap: () => toggleFunction(animated: true),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.calendar_today, color: Colors.black),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            Jiffy(_selectedDay).format("MMMM do yyyy"),
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      Transform.rotate(
                        angle: math.pi * animationValue / 2,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 30,
                        ),
                        alignment: Alignment.center,
                      )
                    ],
                  ),
                ),
              ),
              content: Container(
                child: TableCalendar(
                  focusedDay: DateTime.now(),
                  firstDay: DateTime(1990),
                  lastDay: DateTime(3000),
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                  calendarFormat: _format,
                  onFormatChanged: (format) {
                    setState(() {
                      _format = format;
                    });
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    todayDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(
                          color: Colors.black87,
                          width: 2,
                        ),
                      ),
                    ),
                    todayTextStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    selectedDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (page != 0)
                          setState(() {
                            page = 0;
                          });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: page == 0 ? Colors.black : null,
                        fixedSize: Size(
                          MediaQuery.of(context).size.width,
                          50,
                        ),
                        side: BorderSide(
                          color: Colors.black,
                          width: 1.6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                      ),
                      child: Text(
                        'Absents',
                        style: GoogleFonts.poppins(
                          color: page == 0 ? Colors.white : Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (page != 1)
                          setState(() {
                            page = 1;
                          });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: page == 1 ? Colors.black : null,
                        fixedSize: Size(
                          MediaQuery.of(context).size.width,
                          50,
                        ),
                        side: BorderSide(
                          color: Colors.black,
                          width: 1.6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                      ),
                      child: Text(
                        'Lates',
                        style: GoogleFonts.poppins(
                          color: page == 1 ? Colors.white : Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            FutureBuilder(
              future: page == 0
                  ? FirestoreService().getAbsent(
                      'absent_date', Jiffy(_selectedDay).format('yyyy-MM-dd'))
                  : FirestoreService().getLate(
                      'late_date', Jiffy(_selectedDay).format('yyyy-MM-dd')),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done ||
                    !snapshot.hasData)
                  return Center(
                    child: Text(
                      'No data to show...',
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 18,
                      ),
                    ),
                  );
                else if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  List<dynamic> data = snapshot.data as List<dynamic>;
                  if (data.length > 0)
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: page == 0
                          ? absentDatatable(snapshot.data)
                          : lateDatatable(snapshot.data),
                    );
                  else
                    return Center(
                      child: Text(
                        'No data to show...',
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 18,
                        ),
                      ),
                    );
                } else
                  return Center(
                    child: Text(
                      'No data to show...',
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 18,
                      ),
                    ),
                  );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget absentDatatable(data) {
    List<Absent> absents = data as List<Absent>;
    return DataTable(
      dataRowHeight: 60,
      columns: <DataColumn>[
        DataColumn(
          label: Text(
            'photo',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DataColumn(
          label: Text(
            'id',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DataColumn(
          label: Text(
            'staff_id',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DataColumn(
          label: Text(
            'first_name',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DataColumn(
          label: Text(
            'middle_name',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DataColumn(
          label: Text(
            'last_name',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DataColumn(
          label: Text(
            'absent_date',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
      ],
      rows: absents
          .map(
            (absent) => DataRow(
              cells: <DataCell>[
                DataCell(absent.profileUrl.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(absent.profileUrl),
                        radius: 24)
                    : CircleAvatar()),
                DataCell(
                  Text(
                    absent.id,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    absent.staffId,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    absent.firstName,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    absent.middleName,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    absent.lastName,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    Jiffy(DateTime.parse(absent.absentDate))
                        .format('MMMM dd, yyyy'),
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget lateDatatable(data) {
    List<Late> lates = data as List<Late>;
    return DataTable(
      dataRowHeight: 60,
      columns: <DataColumn>[
        DataColumn(
          label: Text(
            'photo',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DataColumn(
          label: Text(
            'id',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DataColumn(
          label: Text(
            'staff_id',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DataColumn(
          label: Text(
            'first_name',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DataColumn(
          label: Text(
            'middle_name',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DataColumn(
          label: Text(
            'last_name',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DataColumn(
          label: Text(
            'late_date',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
      ],
      rows: lates
          .map(
            (late) => DataRow(
              cells: <DataCell>[
                DataCell(late.profileUrl.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(late.profileUrl),
                        radius: 24)
                    : CircleAvatar()),
                DataCell(
                  Text(
                    late.id,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    late.staffId,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    late.firstName,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    late.middleName,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    late.lastName,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    Jiffy(DateTime.parse(late.lateDate))
                        .format('MMMM dd, yyyy'),
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
