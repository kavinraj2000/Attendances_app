class GreetingData {
  final String text;
  final String image;

  GreetingData(this.text, this.image);
}

GreetingData getGreetingData() {
  final hour = DateTime.now().hour;

  if (hour < 12) {
    return GreetingData(
      'Good Morning',
      'assets/images/sunrise.png',
    );
  } else if (hour < 18) {
    return GreetingData(
      'Good Afternoon',
      'assets/images/sun.png',
    );
  } else {
    return GreetingData(
      'Good Evening',
      'assets/images/night.png',
    );
  }
}
