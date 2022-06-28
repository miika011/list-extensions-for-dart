import 'package:list_extensions/list_extensions.dart';
import 'package:test/test.dart';

String token = "*";
const first = "one";
const second = "two";
const third = "three";
const fourth = "four";

final listWithOneElement = [first];
final listWithTwoElements = [first, second];
final listWithThreeElements = [first, second, third];
final listWithFourElements = [first, second, third, fourth];

String indexedBuilder(int index) => "$token|$index|$token";
String surroundingTokenBuilder(SurroundingToken type) =>
    type == SurroundingToken.first ? "START->" : "<-FINISH";

void main() {
  group('Separated List With Static Tokens', () {
    setUp(() {});

    test('0 elements', () {
      final expected = [];
      separatedTest([], expected, token: token);
    });

    test("1 element", () {
      final expected = [first];
      separatedTest(listWithOneElement, expected, token: token);
    });

    test(
      "2 elements",
      () {
        final expected = [first, token, second];
        separatedTest(listWithTwoElements, expected, token: token);
      },
    );

    test("3 elements", () {
      final expected = [first, token, second, token, third];
      separatedTest(listWithThreeElements, expected, token: token);
    });

    test("4 elements", () {
      final expected = [first, token, second, token, third, token, fourth];
      separatedTest(listWithFourElements, expected, token: token);
    });
  });

  group("Separated List With Token Builder", () {
    const f = indexedBuilder;
    test("0 elements", () {
      final expected = [];
      separatedBuilderTest([], expected, builder: f);
    });

    test("1 element", () {
      final expected = [first];
      separatedBuilderTest(listWithOneElement, expected, builder: f);
    });

    test("2 elements", () {
      final expected = [first, f(0), second];
      separatedBuilderTest(listWithTwoElements, expected, builder: f);
    });

    test("3 elements", () {
      final expected = [first, f(0), second, f(1), third];
      separatedBuilderTest(listWithThreeElements, expected, builder: f);
    });

    test("4 elements", () {
      final expected = [first, f(0), second, f(1), third, f(2), fourth];
      separatedBuilderTest(listWithFourElements, expected, builder: f);
    });
  });

  group("Surrounded List With Static Tokens", () {
    test("0 elements", () {
      final expected = [];
      surroundedTest([], expected, token: token);
    });

    test(
      "1 element",
      () {
        final expected = [token, first, token];
        surroundedTest(listWithOneElement, expected, token: token);
      },
    );

    test(
      "2 elements",
      () {
        final expected = [token, first, second, token];
        surroundedTest(listWithTwoElements, expected, token: token);
      },
    );

    test(
      "3 elements",
      () {
        final expected = [token, first, second, third, token];
        surroundedTest(listWithThreeElements, expected, token: token);
      },
    );

    test(
      "4 elements",
      () {
        final expected = [token, first, second, third, fourth, token];
        surroundedTest(listWithFourElements, expected, token: token);
      },
    );
  });

  group("Surrounded List With Token Builder", () {
    const f = surroundingTokenBuilder;
    test("0 elements", () {
      final expected = [];
      surroundedBuilderTest([], expected, builder: f);
    });

    test("1 element", () {
      final expected = [
        f(SurroundingToken.first),
        first,
        f(SurroundingToken.last)
      ];
      surroundedBuilderTest(listWithOneElement, expected, builder: f);
    });

    test(
      "2 elements",
      () {
        final expected = [
          f(SurroundingToken.first),
          first,
          second,
          f(SurroundingToken.last)
        ];
        surroundedBuilderTest(listWithTwoElements, expected, builder: f);
      },
    );

    test(
      "3 elements",
      () {
        final expected = [
          f(SurroundingToken.first),
          first,
          second,
          third,
          f(SurroundingToken.last)
        ];
        surroundedBuilderTest(listWithThreeElements, expected, builder: f);
      },
    );

    test("4 elements", () {
      final expected = [
        f(SurroundingToken.first),
        first,
        second,
        third,
        fourth,
        f(SurroundingToken.last)
      ];
      surroundedBuilderTest(listWithFourElements, expected, builder: f);
    });

    group("Separated And Surrounded List With Static Token", () {
      test("0 elements", () {
        final expected = [];
        separatedAndSurroundedTest([], expected, token: token);
      });

      test("1 element", () {
        final expected = [token, first, token];
        separatedAndSurroundedTest(listWithOneElement, expected, token: token);
      });

      test("2 elements", () {
        final expected = [token, first, token, second, token];
        separatedAndSurroundedTest(listWithTwoElements, expected, token: token);
      });

      test(
        "3 elements",
        () {
          final expected = [token, first, token, second, token, third, token];
          separatedAndSurroundedTest(listWithThreeElements, expected,
              token: token);
        },
      );

      test("4 elements", () {
        final expected = [
          token,
          first,
          token,
          second,
          token,
          third,
          token,
          fourth,
          token
        ];
        separatedAndSurroundedTest(listWithFourElements, expected,
            token: token);
      });
    });

    group("Separated And Surrounded List With Token Builder", () {
      const f = indexedBuilder;
      test("0 elements", () {
        final expected = [];
        separatedAndSurroundedTestBuilder([], expected, builder: f);
      });

      test("1 element", () {
        final expected = [f(0), first, f(1)];
        separatedAndSurroundedTestBuilder(listWithOneElement, expected,
            builder: f);
      });

      test("2 elements", () {
        final expected = [
          f(0),
          first,
          f(1),
          second,
          f(2),
        ];
        separatedAndSurroundedTestBuilder(listWithTwoElements, expected,
            builder: f);
      });

      test("3 elements", () {
        final expected = [f(0), first, f(1), second, f(2), third, f(3)];
        separatedAndSurroundedTestBuilder(listWithThreeElements, expected,
            builder: f);
      });

      test("4 elements", () {
        final expected = [
          f(0),
          first,
          f(1),
          second,
          f(2),
          third,
          f(3),
          fourth,
          f(4)
        ];
        separatedAndSurroundedTestBuilder(listWithFourElements, expected,
            builder: f);
      });
    });
  });
}

void separatedTest<T>(List<T> originalList, List<T> expected,
    {required T token}) {
  testList(originalList.separatedBy(token), expected);
  testList(SeparatedList(originalList, token: token), expected);
}

void separatedBuilderTest<T>(List<T> originalList, List<T> expected,
    {required T Function(int index) builder}) {
  testList(originalList.separatedByBuilder(builder), expected);
  testList(SeparatedList.builder(originalList, builder: builder), expected);
}

void surroundedTest<T>(List<T> originalList, List<T> expected,
    {required T token}) {
  testList(originalList.surroundedBy(token), expected);
  testList(SurroundedList(originalList, token: token), expected);
}

void surroundedBuilderTest<T>(List<T> originalList, List<T> expected,
    {required T Function(SurroundingToken type) builder}) {
  testList(originalList.surroundedByBuilder(builder), expected);
  testList(SurroundedList.builder(originalList, builder: builder), expected);
}

void separatedAndSurroundedTest<T>(List<T> originalList, List<T> expected,
    {required T token}) {
  testList(originalList.separatedAndSurroundedBy(token), expected);
  testList(SeparatedAndSurroundedList(originalList, token), expected);
}

void separatedAndSurroundedTestBuilder<T>(
    List<T> originalList, List<T> expected,
    {required T Function(int index) builder}) {
  testList(originalList.separatedAndSurroundedByBuilder(builder), expected);
  testList(SeparatedAndSurroundedList.builder(originalList, builder), expected);
}

void testList<T>(List<T> list, expected) {
  testEquals(list, expected);
  rangeSanityTest(list, expectedLength: expected.length);
  testIndexAndIterator(list, expected);
}

void testEquals<T>(List<T> list, List<T> expected) {
  print(
      "=====================\nTesting equality: \n$list\nshould be\n$expected\n=====================");
  expect(list, expected);
}

void rangeSanityTest<T>(List<T> list, {required int expectedLength}) {
  final reason =
      "List should throw a range error with indices outside [0, list.length-1]";
  expect(list.length, expectedLength, reason: "Test correct .length getter");
  expect(() => list[-1], throwsRangeError, reason: reason);
  expect(() => list[list.length], throwsRangeError, reason: reason);
}

void testIndexAndIterator<T>(List<T> list, List<T> expected) {
  for (int i = 0; i < list.length; ++i) {
    expect(list[i], expected[i]);
  }
  final expectedIterator = expected.iterator;
  bool expectedHasMore = expectedIterator.moveNext();
  final iterator = list.iterator;
  bool hasMore = iterator.moveNext();
  for (T item in list) {
    expect(item, expectedIterator.current);
    expect(item, iterator.current);
    expectedHasMore = expectedIterator.moveNext();
    hasMore = iterator.moveNext();
  }

  expect(hasMore, false);
  expect(expectedHasMore, false);
}
