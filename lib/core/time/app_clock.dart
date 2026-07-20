abstract interface class AppClock {
  DateTime now();
}

class SystemAppClock implements AppClock {
  const SystemAppClock();

  @override
  DateTime now() => DateTime.now();
}

class FixedAppClock implements AppClock {
  final DateTime value;

  const FixedAppClock(this.value);

  @override
  DateTime now() => value;
}
