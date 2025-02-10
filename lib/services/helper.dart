class Helper {
  static String msToMmSs(int ms) {
    int seconds = (ms / 1000).truncate();
    int minutes = (seconds / 60).truncate();
    seconds = seconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }
}