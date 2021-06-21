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
