
import 'package:intl/intl.dart';

class AppFormats {
  // Date format: dd/MM/yyyy hh:mm a
  static String dateFormatFullDetail(String date) {
    if (date.isEmpty) return '-';
    return DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(date));
  }

  // Date format: dd/MM/yyyy
  static String dateFormatDDMMYYYY(String date) {
    if (date.isEmpty) return '-';
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
  }

  // Date format: hh:mm
  static String dateFormatHHMM(String date) {
    if (date.isEmpty) return '-';
    return DateFormat('hh:mm').format(DateTime.parse(date));
  }

  // Date format: 2024-11-13T08:36:43.03Z
  static String dateFormatYYYYMMDDTHHMMSSZ(String date) {
    if (date.isEmpty) return '-';
    return "${DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.parse(date).toLocal())}Z";
  }
}