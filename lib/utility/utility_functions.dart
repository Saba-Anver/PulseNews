class UtilityFunctions {
  static String formatCount(int count) {
    if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}K";
    }
    return count.toString();
  }

  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return "${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} ${difference.inMinutes == 1 ? 'min' : 'mins'} ago";
    } else {
      return "Just now";
    }
  }

  static String safeSubstring(String? text, int start, int end) {
    if (text == null || text.isEmpty) {
      return "";
    }
    final maxLength = text.length;
    final safeEnd = end > maxLength ? maxLength : end;

    if (start >= safeEnd) {
      return "";
    }

    return text.substring(start, safeEnd);
  }

  static int min(int a, int b) {
    return a < b ? a : b;
  }
}
