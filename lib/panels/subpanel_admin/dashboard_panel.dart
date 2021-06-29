import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/absent.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/models/late.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/services/firestore_service.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/utils/numeral.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/utils/utils.dart';

class AdminDashboardPanel extends StatefulWidget {
  @override
  _AdminDashboardPanelState createState() => _AdminDashboardPanelState();
}

class _AdminDashboardPanelState extends State<AdminDashboardPanel>
    with SingleTickerProviderStateMixin {
  final Color barBackgroundColor = const Color(0xff72d8bf);
  final Duration animDuration = const Duration(milliseconds: 250);
  int absentTouchedIndex = -1;
  int lateTouchedIndex = -1;

  List<List<Absent>>? absents;
  List<List<Late>>? lates;
  double totalStaffs = 0;
  int totalAbsences = 0;
  int totalLates = 0;
  int totalAbsensesToday = 0;
  int totalLatesToday = 0;

  @override
  void initState() {
    super.initState();

    doInit();
  }

  Future<void> doInit() async {
    totalAbsences = await FirestoreService().getNumberOfAbsences();
    totalStaffs = await FirestoreService().getNumberOfStaffs();
    totalLates = await FirestoreService().getNumberOfLates();

    DateTime _start = firstDayOfWeek(DateTime.now());
    DateTime _end = lastDayOfWeek(DateTime.now());
    List<DateTime> _week = daysInRange(_start, _end).toList();

    absents = [
      await FirestoreService()
          .getAbsent('absent_date', Jiffy(_week[0]).format('yyyy-MM-dd')),
      await FirestoreService()
          .getAbsent('absent_date', Jiffy(_week[1]).format('yyyy-MM-dd')),
      await FirestoreService()
          .getAbsent('absent_date', Jiffy(_week[2]).format('yyyy-MM-dd')),
      await FirestoreService()
          .getAbsent('absent_date', Jiffy(_week[3]).format('yyyy-MM-dd')),
      await FirestoreService()
          .getAbsent('absent_date', Jiffy(_week[4]).format('yyyy-MM-dd')),
    ];

    lates = [
      await FirestoreService()
          .getLate('late_date', Jiffy(_week[0]).format('yyyy-MM-dd')),
      await FirestoreService()
          .getLate('late_date', Jiffy(_week[1]).format('yyyy-MM-dd')),
      await FirestoreService()
          .getLate('late_date', Jiffy(_week[2]).format('yyyy-MM-dd')),
      await FirestoreService()
          .getLate('late_date', Jiffy(_week[3]).format('yyyy-MM-dd')),
      await FirestoreService()
          .getLate('late_date', Jiffy(_week[4]).format('yyyy-MM-dd')),
    ];
  }

  Future<void> _onRefresh() async {
    await doInit();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10,
        ),
        child: LiquidPullToRefresh(
          showChildOpacityTransition: false,
          onRefresh: () => _onRefresh(),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Overview',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blueAccent,
                                Colors.blueAccent.shade700
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: SafeArea(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    Numeral(value: totalAbsences)
                                        .toStringRelative(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 60,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Absents',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepOrangeAccent,
                                Colors.deepOrangeAccent.shade700
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  Numeral(value: totalLates).toStringRelative(),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 60,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Lates',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Graphical Data',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      color: const Color(0xff81e5cd),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text(
                              'Absences',
                              style: TextStyle(
                                  color: const Color(0xff0f4a3c),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              Jiffy(DateTime.now()).format("MMMM do yyyy"),
                              style: TextStyle(
                                  color: const Color(0xff379982),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 38,
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: BarChart(
                                  absentData(),
                                  swapAnimationDuration: animDuration,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      color: const Color(0xff81e5cd),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text(
                              'Lates',
                              style: TextStyle(
                                  color: const Color(0xff0f4a3c),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              Jiffy(DateTime.now()).format("MMMM do yyyy"),
                              style: TextStyle(
                                  color: const Color(0xff379982),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 38,
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: BarChart(
                                  lateData(),
                                  swapAnimationDuration: animDuration,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeAbsentGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + 1 : y,
          colors: isTouched ? [Colors.yellow] : [barColor],
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: totalStaffs,
            colors: [barBackgroundColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  BarChartGroupData makeLateGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + 1 : y,
          colors: isTouched ? [Colors.yellow] : [barColor],
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: totalStaffs,
            colors: [barBackgroundColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingAbsentGroups() => [
        makeAbsentGroupData(
            0, absents == null ? 0 : absents![0].length.toDouble(),
            isTouched: 0 == absentTouchedIndex),
        makeAbsentGroupData(
            1, absents == null ? 0 : absents![1].length.toDouble(),
            isTouched: 1 == absentTouchedIndex),
        makeAbsentGroupData(
            2, absents == null ? 0 : absents![2].length.toDouble(),
            isTouched: 2 == absentTouchedIndex),
        makeAbsentGroupData(
            3, absents == null ? 0 : absents![3].length.toDouble(),
            isTouched: 3 == absentTouchedIndex),
        makeAbsentGroupData(
            4, absents == null ? 0 : absents![4].length.toDouble(),
            isTouched: 4 == absentTouchedIndex),
      ];

  List<BarChartGroupData> showingLateGroups() => [
        makeAbsentGroupData(0, lates == null ? 0 : lates![0].length.toDouble(),
            isTouched: 0 == lateTouchedIndex),
        makeAbsentGroupData(1, lates == null ? 0 : lates![1].length.toDouble(),
            isTouched: 1 == lateTouchedIndex),
        makeAbsentGroupData(2, lates == null ? 0 : lates![2].length.toDouble(),
            isTouched: 2 == lateTouchedIndex),
        makeAbsentGroupData(3, lates == null ? 0 : lates![3].length.toDouble(),
            isTouched: 3 == lateTouchedIndex),
        makeAbsentGroupData(4, lates == null ? 0 : lates![4].length.toDouble(),
            isTouched: 4 == lateTouchedIndex),
      ];

  BarChartData absentData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay;
              switch (group.x.toInt()) {
                case 0:
                  weekDay = 'Monday';
                  break;
                case 1:
                  weekDay = 'Tuesday';
                  break;
                case 2:
                  weekDay = 'Wednesday';
                  break;
                case 3:
                  weekDay = 'Thursday';
                  break;
                case 4:
                  weekDay = 'Friday';
                  break;
                default:
                  throw Error();
              }
              return BarTooltipItem(
                weekDay + '\n',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.y - 1).toString(),
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
        touchCallback: (barTouchResponse) {
          setState(() {
            if (barTouchResponse.spot != null &&
                barTouchResponse.touchInput is! PointerUpEvent &&
                barTouchResponse.touchInput is! PointerExitEvent) {
              absentTouchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
            } else {
              absentTouchedIndex = -1;
            }
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 0:
                return 'Mon';
              case 1:
                return 'Tue';
              case 2:
                return 'Wed';
              case 3:
                return 'Thu';
              case 4:
                return 'Fri';
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingAbsentGroups(),
    );
  }

  BarChartData lateData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay;
              switch (group.x.toInt()) {
                case 0:
                  weekDay = 'Monday';
                  break;
                case 1:
                  weekDay = 'Tuesday';
                  break;
                case 2:
                  weekDay = 'Wednesday';
                  break;
                case 3:
                  weekDay = 'Thursday';
                  break;
                case 4:
                  weekDay = 'Friday';
                  break;
                default:
                  throw Error();
              }
              return BarTooltipItem(
                weekDay + '\n',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.y - 1).toString(),
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
        touchCallback: (barTouchResponse) {
          setState(() {
            if (barTouchResponse.spot != null &&
                barTouchResponse.touchInput is! PointerUpEvent &&
                barTouchResponse.touchInput is! PointerExitEvent) {
              lateTouchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
            } else {
              lateTouchedIndex = -1;
            }
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 0:
                return 'Mon';
              case 1:
                return 'Tue';
              case 2:
                return 'Wed';
              case 3:
                return 'Thu';
              case 4:
                return 'Fri';
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingLateGroups(),
    );
  }
}
