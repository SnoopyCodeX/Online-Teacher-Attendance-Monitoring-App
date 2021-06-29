import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget createMenuItem(
    IconData icon, String label, Function action, bool? isActive) {
  isActive = (isActive == null) ? false : isActive;

  return MaterialButton(
    onPressed: action as Function(),
    color: isActive == true ? Colors.blue.shade300 : null,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(
            width: 10,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18.5,
            ),
          ),
        ],
      ),
    ),
  );
}

String? basename(String name) {
  String base = '';
  if (name.contains('/'))
    for (int i = name.length - 1; i >= 0; i--)
      if (name[i] == '/')
        return base.split('').reversed.join('');
      else
        base += name[i];
  else
    return name;
}

DateTime firstDayOfWeek(DateTime day) {
  day = DateTime.utc(day.year, day.month, day.day, 12);

  int decrease = (day.weekday % 5) - 1;
  return day.subtract(Duration(days: decrease < 0 ? 4 : decrease));
}

DateTime lastDayOfWeek(DateTime day) {
  day = DateTime.utc(day.year, day.month, day.day, 12);

  int increase = day.weekday % 5;
  return day.add(Duration(days: (increase <= 0) ? 0 : 5 - increase));
}

Iterable<DateTime> daysInRange(DateTime start, DateTime end) sync* {
  var i = start;
  var offset = start.timeZoneOffset;
  while (i.isBefore(end)) {
    yield i;
    i = i.add(Duration(days: 1));
    var timeZoneDiff = i.timeZoneOffset - offset;
    if (timeZoneDiff.inSeconds != 0) {
      offset = i.timeZoneOffset;
      i = i.subtract(Duration(seconds: timeZoneDiff.inSeconds));
    }
  }
  yield end;
}
