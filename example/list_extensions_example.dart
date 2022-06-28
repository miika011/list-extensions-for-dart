import 'package:list_extensions/list_extensions.dart';

String divider = "==================";
void main() {
  print("$divider\nStatic tokens:");
  final List<String> originalList = ["one", "two", "three"];
  List<String> surroundedList = originalList.surroundedBy("<>");
  List<String> separatedList = originalList.separatedBy("AND");
  List<String> separatedSurrounded = separatedList.surroundedBy("<>");
  printLists(originalList, surroundedList, separatedList, separatedSurrounded);

  print("Built tokens:");
  surroundedList = originalList.surroundedByBuilder(
      (type) => type == SurroundingToken.first ? "<TAG>" : "</TAG>");
  separatedList =
      originalList.separatedByBuilder((index) => "|SEPARATOR #$index|");
  separatedSurrounded = separatedList.surroundedByBuilder((type) =>
      type == SurroundingToken.first ? "Opening token>>>" : "<<<Closing token");
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
