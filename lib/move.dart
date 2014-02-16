part of chess;

class Move {
  final String color;
  final int from;
  final int to;
  int flags;
  final String piece;
  var promotion;
  var captured;
  Move(this.color, this.from, this.to, this.flags, this.piece);
}