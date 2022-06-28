import 'package:list_extensions/list_extensions.dart';
import 'package:test/test.dart';

class Awesome {
  bool get isAwesome => true;
}

void main() {
  group('A group of tests', () {
    final awesome = Awesome();

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(awesome.isAwesome, isTrue);
    });
  });
}
