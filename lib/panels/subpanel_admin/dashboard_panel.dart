import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/services/firestore_service.dart';
import 'package:online_teacher_staff_attendance_monitoring_app/utils/numeral.dart';

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

  void doInit() async {
    totalAbsences = await FirestoreService().getNumberOfAbsences();
    totalStaffs = await FirestoreService().getNumberOfStaffs();
    totalLates = await FirestoreService().getNumberOfLates();
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  List<BarChartGroupData> showingAbsentGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeAbsentGroupData(0, 0,
                isTouched: i == absentTouchedIndex);
          case 1:
            return makeAbsentGroupData(1, 0,
                isTouched: i == absentTouchedIndex);
          case 2:
            return makeAbsentGroupData(2, 0,
                isTouched: i == absentTouchedIndex);
          case 3:
            return makeAbsentGroupData(3, 0,
                isTouched: i == absentTouchedIndex);
          case 4:
            return makeAbsentGroupData(4, 0,
                isTouched: i == absentTouchedIndex);
          case 5:
            return makeAbsentGroupData(5, 0,
                isTouched: i == absentTouchedIndex);
          case 6:
            return makeAbsentGroupData(6, 0,
                isTouched: i == absentTouchedIndex);
          default:
            return throw Error();
        }
      });

  List<BarChartGroupData> showingLateGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeLateGroupData(0, 0, isTouched: i == lateTouchedIndex);
          case 1:
            return makeLateGroupData(1, 0, isTouched: i == lateTouchedIndex);
          case 2:
            return makeLateGroupData(2, 0, isTouched: i == lateTouchedIndex);
          case 3:
            return makeLateGroupData(3, 0, isTouched: i == lateTouchedIndex);
          case 4:
            return makeLateGroupData(4, 0, isTouched: i == lateTouchedIndex);
          case 5:
            return makeLateGroupData(5, 0, isTouched: i == lateTouchedIndex);
          case 6:
            return makeLateGroupData(6, 0, isTouched: i == lateTouchedIndex);
          default:
            return throw Error();
        }
      });

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
                case 5:
                  weekDay = 'Saturday';
                  break;
                case 6:
                  weekDay = 'Sunday';
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
                return 'M';
              case 1:
                return 'T';
              case 2:
                return 'W';
              case 3:
                return 'T';
              case 4:
                return 'F';
              case 5:
                return 'S';
              case 6:
                return 'S';
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
                case 5:
                  weekDay = 'Saturday';
                  break;
                case 6:
                  weekDay = 'Sunday';
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
                return 'M';
              case 1:
                return 'T';
              case 2:
                return 'W';
              case 3:
                return 'T';
              case 4:
                return 'F';
              case 5:
                return 'S';
              case 6:
                return 'S';
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
