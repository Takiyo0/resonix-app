class Helper {
  static String msToMmSs(int ms) {
    int seconds = (ms / 1000).truncate();
    int minutes = (seconds / 60).truncate();
    seconds = seconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  static String formatDuration(int milliseconds) {
    Duration duration = Duration(milliseconds: milliseconds);

    int days = duration.inDays;
    int hours = duration.inHours % 24;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;

    if (days > 0) return "${days}d ${hours}h";
    if (hours > 0) return "${hours}h ${minutes}m";
    if (minutes > 0) return "${minutes}m ${seconds}s";
    return "$seconds s";
  }

}