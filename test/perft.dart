import "package:chess/chess.dart";

void main() {
  Stopwatch stopwatch = new Stopwatch()
  ..start();
    List perfts = [
    {'fen': 'r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1',
      'depth': 3, 'nodes': 97862},
    {'fen': '8/PPP4k/8/8/8/8/4Kppp/8 w - - 0 1',
      'depth': 4, 'nodes': 89363},
    {'fen': '8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1',
      'depth': 4, 'nodes': 43238},
    {'fen': 'rnbqkbnr/p3pppp/2p5/1pPp4/3P4/8/PP2PPPP/RNBQKBNR w KQkq b6 0 4',
      'depth': 3, 'nodes': 23509},
    ];

    perfts.forEach((perft) {
      Chess chess = new Chess();
      chess.load(perft['fen']);
  
      var nodes = chess.perft(perft['depth']);
    });
  print(stopwatch.elapsedMilliseconds);
}