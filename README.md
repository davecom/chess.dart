chess.dart
==========

chess.dart is a library for legal chess move generation, maintenance of chess game state, and conversion to and from the formats FEN and PGN.  It has no external dependencies.

It is a port of chess.js to Dart.  It aims to include all of the functionality in the original library.  Most of the variable and method names are unchanged.  Indeed, the code is largely a line for line translation from JavaScript to Dart.  It requires cleanup to become more Dart like.

At this early stage, it is working, but bug ridden and largely untested. It is definitely not fit for production.

## A Random Game

```dart
import "package:chess/chess.dart";

void main() {
  Chess chess = new Chess();
  print(chess.ascii());
  while (!chess.game_over()) {
    print('position: ' + chess.fen());
    print(chess.ascii());
    var moves = chess.moves();
    moves.shuffle();
    var move = moves[0];
    chess.move(move);
    print('move: ' + move);
  }
}
```

## Links
chess.js (https://github.com/jhlywa/chess.js)
Wikipedia's Article on FEN Format (http://en.wikipedia.org/wiki/Forsyth–Edwards_Notation)
Wikipedia's Article on PGN Format (http://en.wikipedia.org/wiki/Portable_Game_Notation)
