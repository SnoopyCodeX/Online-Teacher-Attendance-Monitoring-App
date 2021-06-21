import 'dart:core';

class Numeral {
  final int value;

  Numeral({required this.value});

  String toStringRelative() {
    String ret = '';

    if (value <= 999) {
      ret = "$value";
      return ret;
    } else if (value <= 999999 && value >= 1000) {
      dynamic _hund = value % 1000;
      dynamic _thou = (value / 1000).floor();

      if (_hund < 10)
        _hund = "00$_hund";
      else if (_hund < 100 && _hund >= 10)
        _hund = "0$_hund";
      else
        _hund = "$_hund".substring(0, "$_hund".length - 1);

      if ("$_hund"["$_hund".length - 1] == '0')
        _hund = "$_hund".substring(0, "$_hund".length - 1);

      ret = "$_thou.${_hund}K";
      return ret;
    } else if (value <= 999999999 && value >= 1000000) {
      dynamic _thou = value % 1000000;
      dynamic _mill = (value / 1000000).floor();

      if (_thou < 10)
        _thou = "00$_thou";
      else if (_thou < 100 && _thou >= 10)
        _thou = "0$_thou";
      else
        _thou = "$_thou".substring(0, "$_thou".length - 1);

      if ("$_thou"["$_thou".length - 1] == '0')
        _thou = "$_thou".substring(0, "$_thou".length - 1);

      ret = "$_mill.${_thou}M";
      return ret;
    } else if (value <= 999999999999 && value >= 1000000000) {
      dynamic _mill = value % 1000000000;
      dynamic _bill = (value / 1000000000).floor();

      if (_mill < 10)
        _mill = "00$_mill";
      else if (_mill < 100 && _mill >= 10)
        _mill = "0$_mill";
      else
        _mill = "$_mill".substring(0, "$_mill".length - 1);

      if ("$_mill"["$_mill".length - 1] == '0')
        _mill = "$_mill".substring(0, "$_mill".length - 1);

      ret = "$_bill.${_mill}B";
      return ret;
    } else {
      dynamic _bill = value % 1000000000000;
      dynamic _tril = (value / 1000000000000).floor();

      if (_bill < 10)
        _bill = "00$_bill";
      else if (_bill < 100 && _bill >= 10)
        _bill = "0$_bill";
      else
        _bill = "$_bill".substring(0, "$_bill".length - 1);

      if ("$_bill"["$_bill".length - 1] == '0')
        _bill = "$_bill".substring(0, "$_bill".length - 1);

      ret = "$_tril.${_bill}T";
      return ret;
    }
  }
}
