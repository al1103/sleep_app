extension BaseConvertTime on DateTime {
  String getTimeDifference(DateTime from, DateTime to) {
    final difference = to.difference(from);
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} giây';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} tiếng';
    } else {
      return '${difference.inDays} ngày';
    }
  }
}
