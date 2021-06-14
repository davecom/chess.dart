import 'package:chess/chess.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

class PerftBenchmark extends BenchmarkBase {
  final String fen;
  final int depth;
  final int nodes;
  Chess? chess;

  PerftBenchmark(String fen, this.depth, this.nodes)
      : fen = fen
      , super("Perft(fen:'$fen')");

  @override
  void setup() {
    chess = Chess();
    chess!.load(fen);
  }

  @override
  void teardown() {
    chess = null;
  }

  @override
  void run() {
    final result = chess!.perft(depth);
    if (result != nodes) {
      throw 'Wrong result: Expected <$nodes> but got <$result>.';
    }
  }
}

void main() {
  final perfts = [
    PerftBenchmark(
        'r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1',
        3, 97862),
    PerftBenchmark(
        '8/PPP4k/8/8/8/8/4Kppp/8 w - - 0 1',
        4, 89363),
    PerftBenchmark(
        '8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1',
        4, 43238),
    PerftBenchmark(
        'rnbqkbnr/p3pppp/2p5/1pPp4/3P4/8/PP2PPPP/RNBQKBNR w KQkq b6 0 4',
        3, 23509)
  ];
  for (final perft in perfts) {
    perft.report();
  }
}
