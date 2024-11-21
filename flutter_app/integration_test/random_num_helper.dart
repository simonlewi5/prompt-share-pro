import 'dart:math';

class RandomHelper {
  static int generateRandomEmailAndUsername() {
    final random = Random();
    return random.nextInt(90000) + 10000; // Generates a 5-digit number (10000 to 99999
  }
}