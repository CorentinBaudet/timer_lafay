class TimerEntity {
  int duration;

  TimerEntity(this.duration);

  String getTimer() {
    int minutes = (duration ~/ 60);
    double minutesDouble = (duration / 60);
    double minutesDifference = (minutesDouble - minutes);

    if (minutes >= 1) {
      // Higher than a min
      if (minutesDifference != 0) {
        return '${(minutes)}\'${((minutesDifference * 60).round())}"';
      } else {
        return '${(minutes)}\'';
      }
    } else {
      // Lower than a min
      return '${(duration)}"';
    }
  }
}
