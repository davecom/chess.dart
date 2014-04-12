chess.dart
==========

chess.dart is a library for legal chess move generation, maintenance of chess game state, and conversion to and from the formats FEN and PGN.  It has no external dependencies.

It is a port of chess.js to Dart.  It aims to include all of the functionality in the original library, while making the API a little bit more Dart-like. In limited testing, the Dart version (after some refactoring) now outperforms the JavaScript original. 

At this early stage, it is working, and passes all of the unit tests which come with chess.js (which you can find in the *test* directory). However, beyond this, it is not tested in production.

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

The *test* directory contains *tests.dart* which is a port of chess.js's unit tests. The program *random.dart* plays a random game of chess. *ai.dart* is an example of a simple 4 ply alpha beta search for black (yes a simple chess-playing program) that uses a purely material evaluation function (it is rather slow).

## Links
- [chess.js](https://github.com/jhlywa/chess.js)
- [Wikipedia's Article on FEN Format](http://en.wikipedia.org/wiki/Forsyth–Edwards_Notation)
- [Wikipedia's Article on PGN Format](http://en.wikipedia.org/wiki/Portable_Game_Notation)
