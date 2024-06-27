import 'dart:math';

extension RandomString on String {
  static String generateRandomChar({int length = 20}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();

    return List.generate(length, (index) => chars[rnd.nextInt(chars.length)]).join();
  }
}
