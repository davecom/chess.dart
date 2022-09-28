chess.dart
==========

chess.dart is a library for legal chess move generation, maintenance of chess game state, and conversion to and from the formats FEN and PGN.  It has no external dependencies.

In 2014, chess.dart started as a port of chess.js to Dart, including all of the functionality in the original library, while making the API a little bit more Dart-like. It has since accumulated bug fixes and performance improvements thanks to contributions from the Dart community.

chess.dart includes a test suite composed of all of the original chess.js unit tests as well as newer tests specific to bug fixes and feature additions specific to the Dart version (which you can find in the *test* directory). chess.dart is depended upon by multiple popular packages for chess board display.

## Installation

The package is just called `chess` [on pub](https://pub.dev/packages/chess). If for some strange reason you can't use pub, you can also just add the `chess.dart` file from the `lib` directory to your project. Adding the pub package is:

```shell
 $ dart pub add chess
```

Or you can manually add `chess` to your `pubspec.yaml`.

Then importing chess.dart in your code is simply:

```dart
import 'package:chess/chess.dart';
```

## A Random Game

```dart
import "package:chess/chess.dart";

void main() {
  Chess chess = new Chess();
  while (!chess.game_over) {
    print('position: ' + chess.fen);
    print(chess.ascii);
    var moves = chess.moves();
    moves.shuffle();
    var move = moves[0];
    chess.move(move);
    print('move: ' + move);
  }
}
```
## Documentation

The chess.js documentation is largely relevant, but there are also DartDocs generated within the lib/docs directory. The only change in naming from chess.js, is that history() has been changed to getHistory() due to a conflict with the history ivar and some methods have been changed into properties.

### Versioning

chess.dart version 0.6.5 and above requires Dart 2. For Dart 1, use version 0.6.4.

### Testing

The *test* directory contains *tests.dart* which is a port of chess.js's unit tests. The program *random.dart* plays a random game of chess. *ai.dart* is an example of a simple 4 ply alpha beta search for black (yes a simple chess-playing program) that uses a purely material evaluation function (it is rather slow). You can run the unit tests using pub:
```dart
pub get
pub run test/tests.dart
```
And you can also run performance tests.
```dart
pub run test/perft.dart
```
And, finally you can run the simple AI:
```dart
dart test/ai.dart
```

## Links
- [chess on pub.dev](https://pub.dev/packages/chess)
- [chess.js](https://github.com/jhlywa/chess.js)
- [Wikipedia's Article on FEN Format](http://en.wikipedia.org/wiki/Forsyth–Edwards_Notation)
- [Wikipedia's Article on PGN Format](http://en.wikipedia.org/wiki/Portable_Game_Notation)
