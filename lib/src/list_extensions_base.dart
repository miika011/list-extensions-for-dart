// TODO: Put public facing types in this file.

import 'dart:collection';
import 'dart:math';

extension SeparatedIterableExtension<T> on Iterable<T> {
  Iterable<T> separatedBy(T token) {
    return SeparatedIterable(this, separator: token);
  }
}

extension SeparatedListExtension<T> on List<T> {
  SeparatedList<T> separatedBy(T token) => SeparatedList(this, token: token);
  SeparatedList<T> separatedByBuilder(T Function(int index) builder) =>
      SeparatedList.builder(this, builder: builder);
}

extension SurroundedIterableExtension<T> on Iterable<T> {
  Iterable<T> surroundedBy(T token) => SurroundedIterable(this, token: token);
}

extension SurroundedListExtension<T> on List<T> {
  SurroundedList<T> surroundedBy(T token) => SurroundedList(this, token: token);
  SurroundedList<T> surroundedByBuilder(
          T Function(SurroundingToken type) builder) =>
      SurroundedList.builder(this, builder: builder);
}

//Iterator that adds separators between elements like:
// item1 => *SEPARATOR* => item2 => *SEPARATOR* => item3
class SeparatedIterator<T> implements Iterator<T> {
  final Iterator<T> _hookedIterator;
  final T token;
  bool _isNextSeparator = false;
  bool _wasEmpty = false;

  SeparatedIterator(this._hookedIterator, {required this.token}) {
    //We are going to move the iterator 1 step further.
    //So that the first actual moveNext doesn't return the separator.
    //We need to handle the special case when the list is empty
    //since otherwise we'd be calling the hooked iterator's moveNext()
    //after the iterator has already reached end.
    _wasEmpty = !moveNext();
  }

  @override
  T get current {
    return _isNextSeparator ? token : _hookedIterator.current;
  }

  @override
  bool moveNext() {
    if (_wasEmpty) {
      return false;
    }
    bool isAtSeparator = _isNextSeparator;
    _isNextSeparator = !_isNextSeparator;
    return isAtSeparator || _hookedIterator.moveNext();
  }
}

class SeparatedIterable<T> extends IterableMixin<T> {
  final T separator;
  final Iterable<T> _hookedIterable;

  SeparatedIterable(this._hookedIterable, {required this.separator});
  @override
  Iterator<T> get iterator =>
      SeparatedIterator<T>(_hookedIterable.iterator, token: separator);
}

class SeparatedList<T> extends ListMixin<T> {
  @override
  int get length => max(0, _hookedList.length * 2 - 1);
  @override
  set length(val) => throw UnmodifiableError(this);
  // items|  items_with_separators|   list (* is separator)|  num_separators
  // 0    : 0                     :                           0
  // 1    : 1                     : A                         0
  // 2    : 3                     : A * B                     1
  // 3    : 5                     : A * B * C                 2
  // 4    : 7                     : A * B * C * D             3

  //num_separators = max(0,items - 1)

  /* @override
  Iterator<T> get iterator {
    return SeparatedIterator(_hookedList.iterator, separator: separator as T);
  }
*/
  final List<T> _hookedList;
  final T? token;
  late T Function(int index) tokenBuilder;

  SeparatedList(this._hookedList, {required T this.token}) {
    tokenBuilder = (index) => token!;
  }
  SeparatedList.builder(this._hookedList,
      {required T Function(int index) builder})
      : token = null {
    tokenBuilder = builder;
  }

  @override
  T operator [](int index) {
    // let hooked_list = [A,B,C,D] (* is separator)
    //  index|    item
    //  0    :    A (0 on hooked_list)
    //  1    :    * (0 on tokens_index)
    //  2    :    B (1 on hooked_list)
    //  3    :    * (1 on tokens_index)
    //  4    :    C (2 on hooked_list)
    //  5    :    * (2 on tokens_index)
    //  6    :    D (3 on hooked_list)
    if (index.isOdd) {
      return tokenBuilder(index ~/ 2);
    } else {
      return _hookedList[index ~/ 2];
    }
  }

//Don't allow []= assignment.
  @override
  void operator []=(int index, T value) {
    throw UnmodifiableError(this);
  }

  SurroundedList<T> surroundedBy(final T token) =>
      SurroundedList(this, token: token);
}

class SurroundedIterator<T> implements Iterator<T> {
  final Iterator<T> _hookedIterator;
  final T token;
  T? _nextElement;
  _IteratorStatus _status = _IteratorStatus.uninitialized;

  SurroundedIterator(this._hookedIterator, {required this.token});

  @override
  T get current {
    return _nextElement ?? _hookedIterator.current;
  }

  @override
  bool moveNext() {
    switch (_status) {
      case _IteratorStatus.uninitialized: //before first moveNext()
        if (_hookedIterator.moveNext()) {
          _status = _IteratorStatus.atOpening;
          _nextElement = token;
        } else {
          return false; //iterable was empty
        }
        break;

      case _IteratorStatus.atOpening:
        _status = _IteratorStatus.atFirst;
        _nextElement = _hookedIterator.current;
        break;

      case _IteratorStatus.atFirst: //opening surrounding
        if (_hookedIterator.moveNext()) {
          _status = _IteratorStatus.inProgress;
          _nextElement = _hookedIterator.current;
        } else {
          _status = _IteratorStatus.done; //iterable had 1 element
          _nextElement = token;
        }
        break;

      case _IteratorStatus.inProgress:
        if (_hookedIterator.moveNext()) {
          _nextElement = _hookedIterator.current;
        } else {
          _status = _IteratorStatus.done;
          _nextElement = token;
        }
        break;

      case _IteratorStatus.done:
        return false;
    }
    return true;
  }
}

enum _IteratorStatus {
  uninitialized,
  atFirst,
  atOpening,
  inProgress,
  done,
}

class SurroundedIterable<T> extends IterableMixin<T> {
  final Iterable<T> _hookedIterable;
  final T token;

  SurroundedIterable(this._hookedIterable, {required this.token});
  @override
  Iterator<T> get iterator =>
      SurroundedIterator(_hookedIterable.iterator, token: token);
}

class SurroundedList<T> extends ListMixin<T> {
  @override
  int get length => _hookedList.isEmpty ? 0 : _hookedList.length + 2;
  @override
  set length(val) => throw UnmodifiableError(this);
  // items|  items_with_surrounding|   list (* is surrounding)
  // 0    : 0                        :
  // 1    : 3                        : * A *
  // 2    : 4                        : * A B *
  // 3    : 5                        : * A B C *
  // 4    : 6                        : * A B C D *

  final List<T> _hookedList;
  final T? token;
  late T Function(SurroundingToken surroundingToken) itemBuilder;

  SurroundedList(this._hookedList, {required T this.token}) {
    itemBuilder = (index) => token!;
  }
  SurroundedList.builder(this._hookedList,
      {required T Function(SurroundingToken surroundingToken) builder})
      : token = null {
    itemBuilder = builder;
  }

  @override
  T operator [](int index) {
    if (_hookedList.isEmpty) return _hookedList[index];
    final SurroundingToken? surroundingToken = (index == 0)
        ? SurroundingToken.first
        : (index == length - 1)
            ? SurroundingToken.last
            : null;

    return surroundingToken != null
        ? itemBuilder(surroundingToken)
        : _hookedList[index - 1];
  }

  @override
  void operator []=(int index, T value) {
    throw UnmodifiableError(this);
  }
}

class SeparatedAndSurroundedList<T> extends ListMixin<T> {
  late final List<T> _list;

  SeparatedAndSurroundedList(final List<T> list, final T token) {
    _list = list.separatedBy(token).surroundedBy(token);
  }

//  num_items |  num_tokens  | list
//  0         |   0               |  -
//  1         |   2               | * A *
//  2         |   3               | * A * B *
//  3         |   4               | * A * B * C *
// num_tokens = num_items == 0 ? 0 : num_items + 1

  SeparatedAndSurroundedList.builder(
      final List<T> list, T Function(int index) builder) {
    final numTokens = (list.isEmpty) ? 0 : list.length + 1;
    _list = list
        .separatedByBuilder((index) => builder(index + 1))
        .surroundedByBuilder((type) => (type == SurroundingToken.first)
            ? builder(0)
            : builder(numTokens - 1));
  }
  @override
  get length => _list.length;
  @override
  set length(len) => throw UnmodifiableError(this);

  @override
  T operator [](int index) => _list[index];

  @override
  void operator []=(int index, T value) {
    throw UnmodifiableError(this);
  }
}

enum SurroundingToken { first, last }

class UnmodifiableError extends UnsupportedError {
  UnmodifiableError(Object o)
      : super("${o.runtimeType.toString()} is unmodifiable.");
}
