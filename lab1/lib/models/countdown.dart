sealed class Countdown {
  const Countdown();

  factory Countdown.fromDate(DateTime when) {
    final difference = when.difference(DateTime.now());
    if (!difference.isNegative) {
      return Upcoming(difference);
    }
    final elapsed = -difference;
    if (elapsed < const Duration(hours: 1)) {
      return Started(elapsed);
    }
    return const Ended();
  }
}

class Upcoming extends Countdown {
  const Upcoming(this.remaining);

  final Duration remaining;
}

class Started extends Countdown {
  const Started(this.elapsed);

  final Duration elapsed;
}

class Ended extends Countdown {
  const Ended();
}
