import 'package:list_extensions/list_extensions.dart';

String divider = "==================";
void main() {
  print("$divider\nStatic tokens:");
  final List<String> originalList = ["one", "two", "three", "four"];
  List<String> surroundedList =
      originalList.surroundedBy("<>"); // [<>, one, two, three, four, <>]
  List<String> separatedList = originalList
      .separatedBy("AND"); //  [one, AND, two, AND, three, AND, four]
  List<String> separatedSurrounded = originalList.separatedAndSurroundedBy(
      "###"); // [###, one, ###, two, ###, three, ###, four, ###]
  printLists(originalList, surroundedList, separatedList, separatedSurrounded);

  print("Built tokens:");
  surroundedList = originalList.surroundedByBuilder((type) =>
      type == SurroundingToken.first
          ? "<TAG>"
          : "</TAG>"); // [<TAG>, one, two, three, four, </TAG>]
  separatedList = originalList.separatedByBuilder((index) =>
      "|SEPARATOR_$index|"); // [one, |SEPARATOR_0|, two, |SEPARATOR_1|, three, |SEPARATOR_2|, four]
  separatedSurrounded = originalList.separatedAndSurroundedByBuilder((index) =>
      "|TOKEN_$index|"); // [|TOKEN_0|, one, |TOKEN_1|, two, |TOKEN_2|, three, |TOKEN_3|, four, |TOKEN_4|]
  printLists(originalList, surroundedList, separatedList, separatedSurrounded);
}

void printLists(List<String> originalList, List<String> surroundedList,
    List<String> separatedList, List<String> separatedSurrounded) {
  print("Original list: $originalList (length: ${originalList.length})");
  print("Surrounded list: $surroundedList (length: ${surroundedList.length})");
  print("Separated list: $separatedList (length: ${separatedList.length})");
  print(
      "Separated and surrounded list: $separatedSurrounded (length: ${separatedSurrounded.length})\n$divider");
}
