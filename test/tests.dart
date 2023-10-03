import 'package:chess/chess.dart';
import 'package:test/test.dart';

void main() {
  group('Perft', () {
    const perfts = <Map<String, dynamic>>[
      {
        'fen':
            'r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1',
        'depth': 3,
        'nodes': 97862
      },
      {'fen': '8/PPP4k/8/8/8/8/4Kppp/8 w - - 0 1', 'depth': 4, 'nodes': 89363},
      {
        'fen': '8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1',
        'depth': 4,
        'nodes': 43238
      },
      {
        'fen': 'rnbqkbnr/p3pppp/2p5/1pPp4/3P4/8/PP2PPPP/RNBQKBNR w KQkq b6 0 4',
        'depth': 3,
        'nodes': 23509
      },
    ];

    perfts.forEach((perft) {
      final chess = Chess();
      chess.load(perft['fen']);

      test(perft['fen'], () {
        var nodes = chess.perft(perft['depth']);
        expect(nodes, equals(perft['nodes']));
      });
    });
  });

  group('Single Square Move Generation', () {
    const positions = <Map<String, dynamic>>[
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'square': 'e2',
        'verbose': false,
        'moves': ['e3', 'e4']
      },
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'square': 'e9',
        'verbose': false,
        'moves': []
      }, // invalid square
      {
        'fen':
            'rnbqk1nr/pppp1ppp/4p3/8/1b1P4/2N5/PPP1PPPP/R1BQKBNR w KQkq - 2 3',
        'square': 'c3',
        'verbose': false,
        'moves': []
      }, // pinned piece
      {
        'fen': '8/k7/8/8/8/8/7p/K7 b - - 0 1',
        'square': 'h2',
        'verbose': false,
        'moves': ['h1=Q+', 'h1=R+', 'h1=B', 'h1=N']
      }, // promotion
      {
        'fen':
            'r1bq1rk1/1pp2ppp/p1np1n2/2b1p3/2B1P3/2NP1N2/PPPBQPPP/R3K2R w KQ - 0 8',
        'square': 'e1',
        'verbose': false,
        'moves': ['Kf1', 'Kd1', 'O-O', 'O-O-O']
      }, // castling
      {
        'fen':
            'r1bq1rk1/1pp2ppp/p1np1n2/2b1p3/2B1P3/2NP1N2/PPPBQPPP/R3K2R w - - 0 8',
        'square': 'e1',
        'verbose': false,
        'moves': ['Kf1', 'Kd1']
      }, // no castling
      {
        'fen': '8/7K/8/8/1R6/k7/1R1p4/8 b - - 0 1',
        'square': 'a3',
        'verbose': false,
        'moves': []
      }, // trapped king
      {
        'fen': '8/7K/8/8/1R6/k7/1R1p4/8 b - - 0 1',
        'square': 'd2',
        'verbose': true,
        'moves': [
          {
            'color': Chess.BLACK,
            'from': 'd2',
            'to': 'd1',
            'flags': 'np',
            'piece': Chess.PAWN,
            'promotion': Chess.QUEEN,
            'san': 'd1=Q'
          },
          {
            'color': Chess.BLACK,
            'from': 'd2',
            'to': 'd1',
            'flags': 'np',
            'piece': Chess.PAWN,
            'promotion': Chess.ROOK,
            'san': 'd1=R'
          },
          {
            'color': Chess.BLACK,
            'from': 'd2',
            'to': 'd1',
            'flags': 'np',
            'piece': Chess.PAWN,
            'promotion': Chess.BISHOP,
            'san': 'd1=B'
          },
          {
            'color': Chess.BLACK,
            'from': 'd2',
            'to': 'd1',
            'flags': 'np',
            'piece': Chess.PAWN,
            'promotion': Chess.KNIGHT,
            'san': 'd1=N'
          }
        ]
      }, // verbose
      {
        'fen':
            'rnbqk2r/ppp1pp1p/5n1b/3p2pQ/1P2P3/B1N5/P1PP1PPP/R3KBNR b KQkq - 3 5',
        'square': 'f1',
        'verbose': true,
        'moves': []
      }, // issue #30
    ];

    positions.forEach((position) {
      final chess = Chess();
      chess.load(position['fen']);

      test(position['fen'] + ' ' + position['square'], () {
        var moves = chess.moves(
            {'square': position['square'], 'verbose': position['verbose']});
        var passed = position['moves'].length == moves.length;

        for (var j = 0; j < moves.length; j++) {
          if (!position['verbose']) {
            passed = passed && moves[j] == position['moves'][j];
          } else {
            for (var k in moves[j].keys) {
              passed = passed && moves[j][k] == position['moves'][j][k];
            }
          }
        }
        expect(passed, isTrue);
      });
    });
  });

  group('Checkmate', () {
    final chess = Chess();
    const checkmates = [
      '8/5r2/4K1q1/4p3/3k4/8/8/8 w - - 0 7',
      '4r2r/p6p/1pnN2p1/kQp5/3pPq2/3P4/PPP3PP/R5K1 b - - 0 2',
      'r3k2r/ppp2p1p/2n1p1p1/8/2B2P1q/2NPb1n1/PP4PP/R2Q3K w kq - 0 8',
      '8/6R1/pp1r3p/6p1/P3R1Pk/1P4P1/7K/8 b - - 0 4'
    ];

    checkmates.forEach((checkmate) {
      chess.load(checkmate);

      test(checkmate, () {
        expect(chess.in_checkmate, isTrue);
      });
    });
  });

  group('Stalemate', () {
    const stalemates = [
      '1R6/8/8/8/8/8/7R/k6K b - - 0 1',
      '8/8/5k2/p4p1p/P4K1P/1r6/8/8 w - - 0 2',
    ];

    stalemates.forEach((stalemate) {
      final chess = Chess();
      chess.load(stalemate);

      test(stalemate, () {
        expect(chess.in_stalemate, isTrue);
      });
    });
  });

  group('Insufficient Material', () {
    const positions = <Map<String, dynamic>>[
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'draw': false
      },
      {'fen': '8/8/8/8/8/8/8/k6K w - - 0 1', 'draw': true},
      {'fen': '8/2p5/8/8/8/8/8/k6K w - - 0 1', 'draw': false},
      {'fen': '8/2N5/8/8/8/8/8/k6K w - - 0 1', 'draw': true},
      {'fen': '8/2b5/8/8/8/8/8/k6K w - - 0 1', 'draw': true},
      {'fen': '8/b7/3B4/8/8/8/8/k6K w - - 0 1', 'draw': true},
      {'fen': '8/b7/B7/8/8/8/8/k6K w - - 0 1', 'draw': false},
      {'fen': '8/b1B1b1B1/1b1B1b1B/8/8/8/8/1k5K w - - 0 1', 'draw': true},
      {'fen': '8/bB2b1B1/1b1B1b1B/8/8/8/8/1k5K w - - 0 1', 'draw': false}
    ];

    positions.forEach((position) {
      final chess = Chess();
      chess.load(position['fen']);

      test(position['fen'], () {
        if (position['draw']) {
          expect(chess.insufficient_material && chess.in_draw, isTrue);
        } else {
          expect(!chess.insufficient_material && !chess.in_draw, isTrue);
        }
      });
    });
  });

  group('Threefold Repetition', () {
    const positions = <Map<String, dynamic>>[
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'moves': ['Nf3', 'Nf6', 'Ng1', 'Ng8', 'Nf3', 'Nf6', 'Ng1', 'Ng8']
      },

      /* Fischer - Petrosian, Buenos Aires, 1971 */
      {
        'fen': '8/pp3p1k/2p2q1p/3r1P2/5R2/7P/P1P1QP2/7K b - - 2 30',
        'moves': ['Qe5', 'Qh5', 'Qf6', 'Qe2', 'Re5', 'Qd3', 'Rd5', 'Qe2']
      },
    ];

    positions.forEach((position) {
      final chess = Chess();
      chess.load(position['fen']);

      test(position['fen'], () {
        var passed = true;
        for (var j = 0; j < position['moves'].length; j++) {
          if (chess.in_threefold_repetition) {
            passed = false;
            break;
          }
          chess.move(position['moves'][j]);
        }

        expect(
            passed && chess.in_threefold_repetition && chess.in_draw, isTrue);
      });
    });
  });

  group('Algebraic Notation', () {
    const positions = <Map<String, dynamic>>[
      {
        'fen': '7k/3R4/3p2Q1/6Q1/2N1N3/8/8/3R3K w - - 0 1',
        'moves': [
          'Rd8#',
          'Re7',
          'Rf7',
          'Rg7',
          'Rh7#',
          'R7xd6',
          'Rc7',
          'Rb7',
          'Ra7',
          'Qf7',
          'Qe8#',
          'Qg7#',
          'Qg8#',
          'Qh7#',
          'Q6h6#',
          'Q6h5#',
          'Q6f5',
          'Q6f6#',
          'Qe6',
          'Qxd6',
          'Q5f6#',
          'Qe7',
          'Qd8#',
          'Q5h6#',
          'Q5h5#',
          'Qh4#',
          'Qg4',
          'Qg3',
          'Qg2',
          'Qg1',
          'Qf4',
          'Qe3',
          'Qd2',
          'Qc1',
          'Q5f5',
          'Qe5+',
          'Qd5',
          'Qc5',
          'Qb5',
          'Qa5',
          'Na5',
          'Nb6',
          'Ncxd6',
          'Ne5',
          'Ne3',
          'Ncd2',
          'Nb2',
          'Na3',
          'Nc5',
          'Nexd6',
          'Nf6',
          'Ng3',
          'Nf2',
          'Ned2',
          'Nc3',
          'Rd2',
          'Rd3',
          'Rd4',
          'Rd5',
          'R1xd6',
          'Re1',
          'Rf1',
          'Rg1',
          'Rc1',
          'Rb1',
          'Ra1',
          'Kg2',
          'Kh2',
          'Kg1'
        ]
      },
      {
        'fen': '1r3k2/P1P5/8/8/8/8/8/R3K2R w KQ - 0 1',
        'moves': [
          'a8=Q',
          'a8=R',
          'a8=B',
          'a8=N',
          'axb8=Q+',
          'axb8=R+',
          'axb8=B',
          'axb8=N',
          'c8=Q+',
          'c8=R+',
          'c8=B',
          'c8=N',
          'cxb8=Q+',
          'cxb8=R+',
          'cxb8=B',
          'cxb8=N',
          'Ra2',
          'Ra3',
          'Ra4',
          'Ra5',
          'Ra6',
          'Rb1',
          'Rc1',
          'Rd1',
          'Kd2',
          'Ke2',
          'Kf2',
          'Kf1',
          'Kd1',
          'Rh2',
          'Rh3',
          'Rh4',
          'Rh5',
          'Rh6',
          'Rh7',
          'Rh8+',
          'Rg1',
          'Rf1+',
          'O-O+',
          'O-O-O'
        ]
      },
      {
        'fen': '5rk1/8/8/8/8/8/2p5/R3K2R w KQ - 0 1',
        'moves': [
          'Ra2',
          'Ra3',
          'Ra4',
          'Ra5',
          'Ra6',
          'Ra7',
          'Ra8',
          'Rb1',
          'Rc1',
          'Rd1',
          'Kd2',
          'Ke2',
          'Rh2',
          'Rh3',
          'Rh4',
          'Rh5',
          'Rh6',
          'Rh7',
          'Rh8+',
          'Rg1+',
          'Rf1'
        ]
      },
      {
        'fen': '5rk1/8/8/8/8/8/2p5/R3K2R b KQ - 0 1',
        'moves': [
          'Rf7',
          'Rf6',
          'Rf5',
          'Rf4',
          'Rf3',
          'Rf2',
          'Rf1+',
          'Re8+',
          'Rd8',
          'Rc8',
          'Rb8',
          'Ra8',
          'Kg7',
          'Kf7',
          'c1=Q+',
          'c1=R+',
          'c1=B',
          'c1=N'
        ]
      },
      {
        'fen':
            'r3k2r/p2pqpb1/1n2pnp1/2pPN3/1p2P3/2N2Q1p/PPPB1PPP/R3K2R w KQkq c6 0 2',
        'moves': [
          'gxh3',
          'Qxf6',
          'Qxh3',
          'Nxd7',
          'Nxf7',
          'Nxg6',
          'dxc6',
          'dxe6',
          'Rg1',
          'Rf1',
          'Ke2',
          'Kf1',
          'Kd1',
          'Rb1',
          'Rc1',
          'Rd1',
          'g3',
          'g4',
          'Be3',
          'Bf4',
          'Bg5',
          'Bh6',
          'Bc1',
          'b3',
          'a3',
          'a4',
          'Qf4',
          'Qf5',
          'Qg4',
          'Qh5',
          'Qg3',
          'Qe2',
          'Qd1',
          'Qe3',
          'Qd3',
          'Na4',
          'Nb5',
          'Ne2',
          'Nd1',
          'Nb1',
          'Nc6',
          'Ng4',
          'Nd3',
          'Nc4',
          'd6',
          'O-O',
          'O-O-O'
        ]
      },
      {
        'fen': 'k7/8/K7/8/3n3n/5R2/3n4/8 b - - 0 1',
        'moves': [
          'N2xf3',
          'Nhxf3',
          'Nd4xf3',
          'N2b3',
          'Nc4',
          'Ne4',
          'Nf1',
          'Nb1',
          'Nhf5',
          'Ng6',
          'Ng2',
          'Nb5',
          'Nc6',
          'Ne6',
          'Ndf5',
          'Ne2',
          'Nc2',
          'N4b3',
          'Kb8'
        ]
      },
    ];

    positions.forEach((position) {
      final chess = Chess();
      var passed = true;
      chess.load(position['fen']);

      test(position['fen'], () {
        var moves = chess.moves();
        if (moves.length != position['moves'].length) {
          passed = false;
        } else {
          for (var j = 0; j < moves.length; j++) {
            if (!position['moves'].contains(moves[j])) {
              passed = false;
              break;
            }
          }
        }
        expect(passed, isTrue);
      });
    });
  });

  group('Get/Put/Remove', () {
    final chess = Chess();
    var passed = true;
    final positions = <Map<String, dynamic>>[
      {
        'pieces': {
          'a7': Piece(Chess.PAWN, Chess.WHITE),
          'b7': Piece(Chess.PAWN, Chess.BLACK),
          'c7': Piece(Chess.KNIGHT, Chess.WHITE),
          'd7': Piece(Chess.KNIGHT, Chess.BLACK),
          'e7': Piece(Chess.BISHOP, Chess.WHITE),
          'f7': Piece(Chess.BISHOP, Chess.BLACK),
          'g7': Piece(Chess.ROOK, Chess.WHITE),
          'h7': Piece(Chess.ROOK, Chess.BLACK),
          'a6': Piece(Chess.QUEEN, Chess.WHITE),
          'b6': Piece(Chess.QUEEN, Chess.BLACK),
          'a4': Piece(Chess.KING, Chess.WHITE),
          'h4': Piece(Chess.KING, Chess.BLACK)
        },
        'should_pass': true
      },
      {
        'pieces': {'j4': Piece(Chess.PAWN, Chess.WHITE)}, // bad square
        'should_pass': false
      },
    ];

    positions.forEach((position) {
      passed = true;
      chess.clear();

      test('position should pass - ' + position['should_pass'].toString(), () {
        /* places the pieces */
        for (var square in position['pieces'].keys) {
          passed = passed && chess.put(position['pieces'][square], square);
        }

        /* iterate over every square to make sure get returns the proper
         * piece values/color
         */
        for (var square in Chess.SQUARES.keys) {
          if (!(position['pieces'].containsKey(square))) {
            if (chess.get(square) != null) {
              passed = false;
              break;
            }
          } else {
            var piece = chess.get(square);
            if (!(piece != null &&
                piece.type == position['pieces'][square].type &&
                piece.color == position['pieces'][square].color)) {
              passed = false;
              break;
            }
          }
        }

        if (passed) {
          /* remove the pieces */
          for (var square in Chess.SQUARES.keys) {
            final piece = chess.remove(square);
            if ((!(position['pieces'].containsKey(square))) && piece != null) {
              passed = false;
              break;
            }

            if (piece != null &&
                (position['pieces'][square].type != piece.type ||
                    position['pieces'][square].color != piece.color)) {
              passed = false;
              break;
            }
          }
        }

        /* finally, check for an empty board */
        passed = passed && (chess.fen == '8/8/8/8/8/8/8/8 w - - 0 1');

        /* some tests should fail, so make sure we're supposed to pass/fail each
         * test
         */
        passed = (passed == position['should_pass']);

        expect(passed, isTrue);
      });
    });
  });

  group('FEN', () {
    var positions = [
      {'fen': '8/8/8/8/8/8/8/8 w - - 0 1', 'should_pass': true},
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'should_pass': true
      },
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1',
        'should_pass': true
      },
      {
        'fen': '1nbqkbn1/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/1NBQKBN1 b - - 1 2',
        'should_pass': true
      },

      /* incomplete FEN string */
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBN w KQkq - 0 1',
        'should_pass': false
      },

      /* bad digit (9)*/
      {
        'fen': 'rnbqkbnr/pppppppp/9/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'should_pass': false
      },

      /* bad piece (X)*/
      {
        'fen': '1nbqkbn1/pppp1ppX/8/4p3/4P3/8/PPPP1PPP/1NBQKBN1 b - - 1 2',
        'should_pass': false
      },

      /* no king */
      {'fen': '8/8/8/4n3/2p5/2P5/4N3/8 b - - 0 40', 'should_pass': false},

      /* 2 white kings */
      {'fen': '2k5/8/8/4n3/2p5/2P5/4N3/K6K w - - 0 40', 'should_pass': false},

      /* 2 black kings */
      {'fen': '2k5/8/5k2/4n3/2p5/2P5/4N3/7K w - - 0 40', 'should_pass': false},

      /* both kings are on neighbours cells */
      {'fen': '2k5/3K4/8/4n3/2p5/2P5/4N3/8 w - - 0 40', 'should_pass': false},

      /* pawn on first rank */
      {'fen': '8/8/4k3/8/8/2K5/8/4P3 w - - 0 1', 'should_pass': false},
      {'fen': '8/8/4k3/8/8/2K5/8/p7 w - - 0 1', 'should_pass': false},

      /* pawn on 8th rank */
      {'fen': '2p5/8/4k3/8/8/2K5/8/8 w - - 0 1', 'should_pass': false},
      {'fen': '5P2/8/4k3/8/8/2K5/8/8 w - - 0 1', 'should_pass': false},
    ];

    positions.forEach((position) {
      final chess = Chess();

      test(
          position['fen'].toString() +
              ' (' +
              position['should_pass'].toString() +
              ')', () {
        chess.load(position['fen'] as String);
        expect(
            (chess.fen == position['fen']) == position['should_pass'], isTrue);
      });
    });
  });

  group('PGN', () {
    //bool passed = true;
    //var error_message;
    const positions = <Map<String, dynamic>>[
      {
        'moves': [
          'd4',
          'd5',
          'Nf3',
          'Nc6',
          'e3',
          'e6',
          'Bb5',
          'g5',
          'O-O',
          'Qf6',
          'Nc3',
          'Bd7',
          'Bxc6',
          'Bxc6',
          'Re1',
          'O-O-O',
          'a4',
          'Bb4',
          'a5',
          'b5',
          'axb6',
          'axb6',
          'Ra8+',
          'Kd7',
          'Ne5+',
          'Kd6',
          'Rxd8+',
          'Qxd8',
          'Nxf7+',
          'Ke7',
          'Nxd5+',
          'Qxd5',
          'c3',
          'Kxf7',
          'Qf3+',
          'Qxf3',
          'gxf3',
          'Bxf3',
          'cxb4',
          'e5',
          'dxe5',
          'Ke6',
          'b3',
          'Kxe5',
          'Bb2+',
          'Ke4',
          'Bxh8',
          'Nf6',
          'Bxf6',
          'h5',
          'Bxg5',
          'Bg2',
          'Kxg2',
          'Kf5',
          'Bh4',
          'Kg4',
          'Bg3',
          'Kf5',
          'e4+',
          'Kg4',
          'e5',
          'h4',
          'Bxh4',
          'Kxh4',
          'e6',
          'c5',
          'bxc5',
          'bxc5',
          'e7',
          'c4',
          'bxc4',
          'Kg4',
          'e8=Q',
          'Kf5',
          'Qe5+',
          'Kg4',
          'Re4#'
        ],
        'header': [
          'White',
          'Jeff Hlywa',
          'Black',
          'Steve Bragg',
          'GreatestGameEverPlayed?',
          'True'
        ],
        'max_width': 19,
        'newline_char': '<br />',
        'pgn':
            '[White "Jeff Hlywa"]<br />[Black "Steve Bragg"]<br />[GreatestGameEverPlayed? "True"]<br /><br />1. d4 d5 2. Nf3 Nc6<br />3. e3 e6 4. Bb5 g5<br />5. O-O Qf6<br />6. Nc3 Bd7<br />7. Bxc6 Bxc6<br />8. Re1 O-O-O<br />9. a4 Bb4 10. a5 b5<br />11. axb6 axb6<br />12. Ra8+ Kd7<br />13. Ne5+ Kd6<br />14. Rxd8+ Qxd8<br />15. Nxf7+ Ke7<br />16. Nxd5+ Qxd5<br />17. c3 Kxf7<br />18. Qf3+ Qxf3<br />19. gxf3 Bxf3<br />20. cxb4 e5<br />21. dxe5 Ke6<br />22. b3 Kxe5<br />23. Bb2+ Ke4<br />24. Bxh8 Nf6<br />25. Bxf6 h5<br />26. Bxg5 Bg2<br />27. Kxg2 Kf5<br />28. Bh4 Kg4<br />29. Bg3 Kf5<br />30. e4+ Kg4<br />31. e5 h4<br />32. Bxh4 Kxh4<br />33. e6 c5<br />34. bxc5 bxc5<br />35. e7 c4<br />36. bxc4 Kg4<br />37. e8=Q Kf5<br />38. Qe5+ Kg4<br />39. Re4#',
        'fen': '8/8/8/4Q3/2P1R1k1/8/5PKP/8 b - - 4 39'
      },
      {
        'moves': [
          'c4',
          'e6',
          'Nf3',
          'd5',
          'd4',
          'Nf6',
          'Nc3',
          'Be7',
          'Bg5',
          'O-O',
          'e3',
          'h6',
          'Bh4',
          'b6',
          'cxd5',
          'Nxd5',
          'Bxe7',
          'Qxe7',
          'Nxd5',
          'exd5',
          'Rc1',
          'Be6',
          'Qa4',
          'c5',
          'Qa3',
          'Rc8',
          'Bb5',
          'a6',
          'dxc5',
          'bxc5',
          'O-O',
          'Ra7',
          'Be2',
          'Nd7',
          'Nd4',
          'Qf8',
          'Nxe6',
          'fxe6',
          'e4',
          'd4',
          'f4',
          'Qe7',
          'e5',
          'Rb8',
          'Bc4',
          'Kh8',
          'Qh3',
          'Nf8',
          'b3',
          'a5',
          'f5',
          'exf5',
          'Rxf5',
          'Nh7',
          'Rcf1',
          'Qd8',
          'Qg3',
          'Re7',
          'h4',
          'Rbb7',
          'e6',
          'Rbc7',
          'Qe5',
          'Qe8',
          'a4',
          'Qd8',
          'R1f2',
          'Qe8',
          'R2f3',
          'Qd8',
          'Bd3',
          'Qe8',
          'Qe4',
          'Nf6',
          'Rxf6',
          'gxf6',
          'Rxf6',
          'Kg8',
          'Bc4',
          'Kh8',
          'Qf4'
        ],
        'header': [
          'Event',
          'Reykjavik WCh',
          'Site',
          'Reykjavik WCh',
          'Date',
          '1972.01.07',
          'EventDate',
          '?',
          'Round',
          '6',
          'Result',
          '1-0',
          'White',
          'Robert James Fischer',
          'Black',
          'Boris Spassky',
          'ECO',
          'D59',
          'WhiteElo',
          '?',
          'BlackElo',
          '?',
          'PlyCount',
          '81'
        ],
        'max_width': 65,
        'pgn':
            '[Event "Reykjavik WCh"]\n[Site "Reykjavik WCh"]\n[Date "1972.01.07"]\n[EventDate "?"]\n[Round "6"]\n[Result "1-0"]\n[White "Robert James Fischer"]\n[Black "Boris Spassky"]\n[ECO "D59"]\n[WhiteElo "?"]\n[BlackElo "?"]\n[PlyCount "81"]\n\n1. c4 e6 2. Nf3 d5 3. d4 Nf6 4. Nc3 Be7 5. Bg5 O-O 6. e3 h6\n7. Bh4 b6 8. cxd5 Nxd5 9. Bxe7 Qxe7 10. Nxd5 exd5 11. Rc1 Be6\n12. Qa4 c5 13. Qa3 Rc8 14. Bb5 a6 15. dxc5 bxc5 16. O-O Ra7\n17. Be2 Nd7 18. Nd4 Qf8 19. Nxe6 fxe6 20. e4 d4 21. f4 Qe7\n22. e5 Rb8 23. Bc4 Kh8 24. Qh3 Nf8 25. b3 a5 26. f5 exf5\n27. Rxf5 Nh7 28. Rcf1 Qd8 29. Qg3 Re7 30. h4 Rbb7 31. e6 Rbc7\n32. Qe5 Qe8 33. a4 Qd8 34. R1f2 Qe8 35. R2f3 Qd8 36. Bd3 Qe8\n37. Qe4 Nf6 38. Rxf6 gxf6 39. Rxf6 Kg8 40. Bc4 Kh8 41. Qf4 1-0',
        'fen': '4q2k/2r1r3/4PR1p/p1p5/P1Bp1Q1P/1P6/6P1/6K1 b - - 4 41'
      },
      {
        'moves': [
          'e7+',
          'Ke8',
          'Ke6'
        ],
        'header': [],
        'max_width': 80,
        'starting_position': '3k4/8/3KP3/8/8/8/8/8 w - - 0 42',
        'pgn':
            '[SetUp "1"]\n[FEN "3k4/8/3KP3/8/8/8/8/8 w - - 0 42"]\n\n42. e7+ Ke8 43. Ke6',
        'fen': '4k3/4P3/4K3/8/8/8/8/8 b - - 2 43'
      },
      {
        'moves': [
          'Ke8',
          'e7',
          'Kf7',
          'Kd7'
        ],
        'header': [],
        'max_width': 80,
        'starting_position': '3k4/8/3KP3/8/8/8/8/8 b - - 0 39',
        'pgn':
            '[SetUp "1"]\n[FEN "3k4/8/3KP3/8/8/8/8/8 b - - 0 39"]\n\n39. ... Ke8 40. e7 Kf7 41. Kd7',
        'fen': '8/3KPk2/8/8/8/8/8/8 b - - 2 41'
      },
      {
        'moves': [
          'f3',
          'e5',
          'g4',
          'Qh4#'
        ], // testing max_width being small and having no comments
        'header': [],
        'max_width': 1,
        'pgn': '1. f3 e5\n2. g4 Qh4#',
        'fen': 'rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 1 3'
      },
      {
        'moves': ['Ba5', 'O-O', 'd6', 'd4'], // testing a non-starting position
        'header': [],
        'max_width': 20,
        'pgn':
            '[SetUp "1"]\n[FEN "r1bqk1nr/pppp1ppp/2n5/4p3/1bB1P3/2P2N2/P2P1PPP/RNBQK2R b KQkq - 0 1"]\n\n1. ... Ba5 2. O-O d6\n3. d4',
        'starting_position':
            'r1bqk1nr/pppp1ppp/2n5/4p3/1bB1P3/2P2N2/P2P1PPP/RNBQK2R b KQkq - 0 1',
        'fen':
            'r1bqk1nr/ppp2ppp/2np4/b3p3/2BPP3/2P2N2/P4PPP/RNBQ1RK1 b kq d3 0 3'
      }
    ];

    positions.forEach((position) {
      test(position['fen'], () {
        final chess = (position.containsKey('starting_position'))
            ? Chess.fromFEN(position['starting_position'])
            : Chess();
        var passed = true;
        var error_message = '';
        for (var j = 0; j < position['moves'].length; j++) {
          if (!chess.move(position['moves'][j])) {
            error_message =
                'move() did not accept ' + position['moves'][j] + ' : ';
            break;
          }
        }

        for (var k = 0; k < position['header'].length; k += 2) {
          chess.header[position['header'][k]] = position['header'][k + 1];
        }
        //chess.header.apply(null, position['header']);
        var pgn = chess.pgn({
          'max_width': position['max_width'],
          'newline_char': position['newline_char']
        });
        var fen = chess.fen;
        passed = pgn == position['pgn'] && fen == position['fen'];
        expect(passed && error_message.isEmpty, isTrue);
      });
    });
  });

  group('Load PGN', () {
    final chess = Chess();
    const tests = <Map<String, dynamic>>[
      {
        'pgn': [
          '[Event "Reykjavik WCh"]',
          '[Site "Reykjavik WCh"]',
          '[Date "1972.01.07"]',
          '[EventDate "?"]',
          '[Round "6"]',
          '[Result "1-0"]',
          '[White "Robert James Fischer"]',
          '[Black "Boris Spassky"]',
          '[ECO "D59"]',
          '[WhiteElo "?"]',
          '[BlackElo "?"]',
          '[PlyCount "81"]',
          '',
          '1. c4 e6 2. Nf3 d5 3. d4 Nf6 4. Nc3 Be7 5. Bg5 O-O 6. e3 h6',
          '7. Bh4 b6 8. cxd5 Nxd5 9. Bxe7 Qxe7 10. Nxd5 exd5 11. Rc1 Be6',
          '12. Qa4 c5 13. Qa3 Rc8 14. Bb5 a6 15. dxc5 bxc5 16. O-O Ra7',
          '17. Be2 Nd7 18. Nd4 Qf8 19. Nxe6 fxe6 20. e4 d4 21. f4 Qe7',
          '22. e5 Rb8 23. Bc4 Kh8 24. Qh3 Nf8 25. b3 a5 26. f5 exf5',
          '27. Rxf5 Nh7 28. Rcf1 Qd8 29. Qg3 Re7 30. h4 Rbb7 31. e6 Rbc7',
          '32. Qe5 Qe8 33. a4 Qd8 34. R1f2 Qe8 35. R2f3 Qd8 36. Bd3 Qe8',
          '37. Qe4 Nf6 38. Rxf6 gxf6 39. Rxf6 Kg8 40. Bc4 Kh8 41. Qf4 1-0'
        ],
        'expect': true
      },
      {
        'fen': '1n1Rkb1r/p4ppp/4q3/4p1B1/4P3/8/PPP2PPP/2K5 b k - 1 17',
        'pgn': [
          '[Event "Paris"]',
          '[Site "Paris"]',
          '[Date "1858.??.??"]',
          '[EventDate "?"]',
          '[Round "?"]',
          '[Result "1-0"]',
          '[White "Paul Morphy"]',
          '[Black "Duke Karl / Count Isouard"]',
          '[ECO "C41"]',
          '[WhiteElo "?"]',
          '[BlackElo "?"]',
          '[PlyCount "33"]',
          '',
          '1.e4 e5 2.Nf3 d6 3.d4 Bg4 {This is a weak move',
          'already.--Fischer} 4.dxe5 Bxf3 5.Qxf3 dxe5 6.Bc4 Nf6 7.Qb3 Qe7',
          '8.Nc3 c6 9.Bg5 {Black is in what\'s like a zugzwang position',
          'here. He can\'t develop the [Queen\'s] knight because the pawn',
          'is hanging, the bishop is blocked because of the',
          'Queen.--Fischer} b5 10.Nxb5 cxb5 11.Bxb5+ Nbd7 12.O-O-O Rd8',
          '13.Rxd7 Rxd7 14.Rd1 Qe6 15.Bxd7+ Nxd7 16.Qb8+ Nxb8 17.Rd8# 1-0'
        ],
        'expect': true
      },
      {
        'pgn': [
          '1. e4 e5 2. f4 exf4 3. Nf3 g5 4. h4 g4 5. Ne5 Nf6 6. Nxg4 Nxe4',
          '7. d3 Ng3 8. Bxf4 Nxh1 9. Qe2+ Qe7 10. Nf6+ Kd8 11. Bxc7+ Kxc7',
          '12. Nd5+ Kd8 13. Nxe7 Bxe7 14. Qg4 d6 15. Qf4 Rg8 16. Qxf7 Bxh4+',
          '17. Kd2 Re8 18. Na3 Na6 19. Qh5 Bf6 20. Qxh1 Bxb2 21. Qh4+ Kd7',
          '22. Rb1 Bxa3 23. Qa4+'
        ],
        'expect': true
      },
      /* regression test - broken PGN parser ended up here:
       * fen = rnbqk2r/pp1p1ppp/4pn2/1N6/1bPN4/8/PP2PPPP/R1BQKB1R b KQkq - 2 6 */
      {
        'pgn': ['1. d4 Nf6 2. c4 e6 3. Nf3 c5 4. Nc3 cxd4 5. Nxd4 Bb4 6. Nb5'],
        'fen':
            'rnbqk2r/pp1p1ppp/4pn2/1N6/1bP5/2N5/PP2PPPP/R1BQKB1R b KQkq - 2 6',
        'expect': true
      },
      {
        'pgn': ['1. e4 Qxd7 1/2-1/2'],
        'expect': false
      },
    ];

    var newline_chars = ['\n', '<br />', '\r\n', 'BLAH'];

    tests.forEach((t) {
      newline_chars.forEach((newline) {
        test(t['fen'], () {
          var result =
              chess.load_pgn(t['pgn'].join(newline), {'newline_char': newline});
          bool should_pass = t['expect'];

          /* some tests are expected to fail */
          if (should_pass) {
            /* some PGN's tests contain comments which are stripped during parsing,
           * so we'll need compare the results of the load against a FEN string
           * (instead of the reconstructed PGN [e.g. test.pgn.join(newline)])
           */

            if (t.containsKey('fen')) {
              expect(result, isTrue);
              expect(chess.fen, equals(t['fen']));
              //print(chess.fen());
              //print(t["fen"]);
            } else {
              expect(result, isTrue);
              expect(chess.pgn({'max_width': 65, 'newline_char': newline}),
                  equals(t['pgn'].join(newline)));
              //print(chess.pgn({ 'max_width': 65, 'newline_char': newline }));
              //print(t['pgn'].join(newline));
            }
          } else {
            /* this test should fail, so make sure it does */
            expect(result, equals(should_pass));
          }
        });
      });
    });

    test('with variations', () {
      var pgnWithVariations = '''
        1. e4 c5 2. Nc3 Nc6 (2... d6 3. f4 Nc6 4. Nf3 g6 5. Bb5 Bd7 (5... Bg7) 6. O-O
        Bg7 7. d3 a6 (7... Nf6) 8. Bxc6 Bxc6 9. Be3 Nf6 10. h3 O-O 11. Qd2; 2... e6 3.
        Nf3 a6 (3... Nc6 4. d4 cxd4 5. Nxd4 Qc7 (5... a6; 5... d6) 6. Be2 a6 (6... Nf6)
        7. O-O Nf6 8. Be3 Bb4 (8... Be7) 9. Na4 Be7 (9... O-O 10. Nxc6 bxc6 11. Nb6 Rb8
        12. Nxc8 Rfxc8 (12... Qxc8 13. e5) 13. Bxa6; 9... Bd6 10. g3 b5 11. Nb6 Rb8
        (11... Qxb6 12. Nxb5 Bc5 13. Bxc5 Qxc5 14. Nc7+) 12. Nxc8 Rxc8 13. a4) 10. Nxc6
        bxc6 11. Nb6 Rb8 12. Nxc8 Qxc8 13. Bd4; 3... d6 4. d4 cxd4 5. Nxd4 Nf6 6. Be2
        Be7 7. O-O O-O 8. f4 Nc6 9. Be3 Bd7 10. Nb3; 3... Nf6 4. e5 Nd5 5. Nxd5 exd5 6.
        d4 Nc6 7. dxc5 Bxc5 8. Qxd5 Qb6 9. Bc4 Bxf2+ 10. Ke2 O-O 11. Rf1 Bc5 12. Ng5
        Nd4+ 13. Kd1 Ne6 14. Ne4 d6 15. exd6 Rd8 16. Bd3 Bxd6 17. Nxd6 Qxd6 18. Qf5))
        3. Nf3 e6 (3... d6 4. d4 cxd4 5. Nxd4 Nf6 6. Bg5; 3... g6; 3... e5; 3... Nf6)
        4. d4 cxd4 5. Nxd4 Qc7 (5... a6; 5... d6) 6. Be2 a6 (6... Nf6) 7. O-O Nf6 8.
        Be3 Bb4 (8... Be7) 9. Na4 Be7 (9... O-O 10. Nxc6 bxc6 11. Nb6 Rb8 12. Nxc8
        Rfxc8 (12... Qxc8 13. e5) 13. Bxa6; 9... Bd6 10. g3 b5 11. Nb6 Rb8 (11... Qxb6
        12. Nxb5 Bc5 13. Bxc5 Qxc5 14. Nc7+) 12. Nxc8 Rxc8 13. a4) 10. Nxc6 bxc6 11.
        Nb6 Rb8 12. Nxc8 Qxc8 13. Bd4''';
      var mainPgn =
          '1. e4 c5 2. Nc3 Nc6 3. Nf3 e6 4. d4 cxd4 5. Nxd4 Qc7 6. Be2 a6\n'
          '7. O-O Nf6 8. Be3 Bb4 9. Na4 Be7 10. Nxc6 bxc6 11. Nb6 Rb8\n'
          '12. Nxc8 Qxc8 13. Bd4';

      var result = chess.load_pgn(pgnWithVariations);
      expect(result, true);

      expect(
          chess.pgn({
            'max_width': 65,
            'newline_char': '\n',
          }),
          equals(mainPgn));
    });

    // special case dirty file containing a mix of \n and \r\n
    test('dirty pgn', () {
      var pgn = '[Event "Reykjavik WCh"]\n'
          '[Site "Reykjavik WCh"]\n'
          '[Date "1972.01.07"]\n'
          '[EventDate "?"]\n'
          '[Round "6"]\n'
          '[Result "1-0"]\n'
          '[White "Robert James Fischer"]\r\n'
          '[Black "Boris Spassky"]\n'
          '[ECO "D59"]\n'
          '[WhiteElo "?"]\n'
          '[BlackElo "?"]\n'
          '[PlyCount "81"]\n'
          '\r\n'
          '1. c4 e6 2. Nf3 d5 3. d4 Nf6 4. Nc3 Be7 5. Bg5 O-O 6. e3 h6\n'
          '7. Bh4 b6 8. cxd5 Nxd5 9. Bxe7 Qxe7 10. Nxd5 exd5 11. Rc1 Be6\n'
          '12. Qa4 c5 13. Qa3 Rc8 14. Bb5 a6 15. dxc5 bxc5 16. O-O Ra7\n'
          '17. Be2 Nd7 18. Nd4 Qf8 19. Nxe6 fxe6 20. e4 d4 21. f4 Qe7\r\n'
          '22. e5 Rb8 23. Bc4 Kh8 24. Qh3 Nf8 25. b3 a5 26. f5 exf5\n'
          '27. Rxf5 Nh7 28. Rcf1 Qd8 29. Qg3 Re7 30. h4 Rbb7 31. e6 Rbc7\n'
          '32. Qe5 Qe8 33. a4 Qd8 34. R1f2 Qe8 35. R2f3 Qd8 36. Bd3 Qe8\n'
          '37. Qe4 Nf6 38. Rxf6 gxf6 39. Rxf6 Kg8 40. Bc4 Kh8 41. Qf4 1-0\n';

      var result = chess.load_pgn(pgn, {'newline_char': '\r?\n'});
      expect(result, isNotNull);

      expect(chess.load_pgn(pgn), isNotNull);
      expect(!chess.pgn().contains(RegExp(r'^\[\[')), isTrue);
    });
  });

  group('Make Move', () {
    const positions = <Map<String, dynamic>>[
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'legal': true,
        'move': 'e4',
        'next': 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1'
      },
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'legal': false,
        'move': 'e5'
      },
      {
        'fen': '7k/3R4/3p2Q1/6Q1/2N1N3/8/8/3R3K w - - 0 1',
        'legal': true,
        'move': 'Rd8#',
        'next': '3R3k/8/3p2Q1/6Q1/2N1N3/8/8/3R3K b - - 1 1'
      },
      {
        'fen': 'rnbqkbnr/pp3ppp/2pp4/4pP2/4P3/8/PPPP2PP/RNBQKBNR w KQkq e6 0 1',
        'legal': true,
        'move': 'fxe6',
        'next': 'rnbqkbnr/pp3ppp/2ppP3/8/4P3/8/PPPP2PP/RNBQKBNR b KQkq - 0 1',
        'captured': Chess.PAWN
      },
      {
        'fen': 'rnbqkbnr/pppp2pp/8/4p3/4Pp2/2PP4/PP3PPP/RNBQKBNR b KQkq e3 0 1',
        'legal': true,
        'move': 'fxe3',
        'next': 'rnbqkbnr/pppp2pp/8/4p3/8/2PPp3/PP3PPP/RNBQKBNR w KQkq - 0 2',
        'captured': Chess.PAWN
      }
    ];

    positions.forEach((position) {
      final chess = Chess();
      chess.load(position['fen']);
      test(
          position['fen'] +
              ' (' +
              position['move'] +
              ' ' +
              position['legal'].toString() +
              ')', () {
        var result = chess.move(position['move']);
        if (position['legal']) {
          expect(result, isTrue);
          expect(chess.fen, equals(position['next']));
          if (position.containsKey('captured')) {
            expect(chess.history.removeLast().move.captured,
                equals(position['captured']));
          }
        } else {
          expect(result, isFalse);
        }
      });
    });
  });

  group('Validate FEN', () {
    //Chess chess = new Chess();
    const positions = <Map<String, dynamic>>[
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNRw KQkq - 0 1',
        'error_number': 1
      },
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 x',
        'error_number': 2
      },
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 0',
        'error_number': 2
      },
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 -1',
        'error_number': 2
      },
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - x 1',
        'error_number': 3
      },
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - -1 1',
        'error_number': 3
      },
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq e2 0 1',
        'error_number': 4
      },
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq e7 0 1',
        'error_number': 4
      },
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq x 0 1',
        'error_number': 4
      },
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQxkq - 0 1',
        'error_number': 5
      },
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w kqKQ - 0 1',
        'error_number': 5
      },
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR ? KQkq - 0 1',
        'error_number': 6
      },
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP w KQkq - 0 1',
        'error_number': 7
      },
      {
        'fen': 'rnbqkbnr/pppppppp/17/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'error_number': 8
      },
      {
        'fen': 'rnbqk?nr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'error_number': 9
      },
      {
        'fen': 'rnbqkbnr/pppppppp/7/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'error_number': 10
      },
      {
        'fen': 'rnbqkbnr/p1p1p1p1p/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'error_number': 10
      },
      {'fen': '8/1p6/2k1K3/8/3K4/8/6P1/8 w - - 0 1', 'error_number': 11},
      {'fen': '8/8/2knk3/8/8/8/5P2/8 b - - 0 1', 'error_number': 11},
      {'fen': '8/8/2knk3/8/8/2K5/5P2/8 b - - 0 1', 'error_number': 11},
      {'fen': '8/8/3n4/8/3k4/2K5/5P2/8 b - - 0 1', 'error_number': 12},
      {'fen': '6p1/3k1n2/8/8/8/8/3K4/8 w - - 0 1', 'error_number': 13},
      {'fen': '8/3k1n2/8/8/8/8/3K4/6p1 w - - 0 1', 'error_number': 13},
      {'fen': '3k4/8/1B6/8/8/8/2K5/8 w - - 0 1', 'error_number': 14},
      {'fen': '3k4/8/8/8/8/4n3/2K5/8 b - - 0 1', 'error_number': 14},
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'error_number': 0
      },
      {
        'fen': 'rnbqkbnr/pppp1ppp/8/4p3/2P5/8/PP1PPPPP/RNBQKBNR w KQkq e6 0 2',
        'error_number': 0
      },
      {
        'fen':
            '3r2k1/p1q2pp1/2nr1n1p/2p1p3/4P2B/P1P2Q1P/B4PP1/1R2R1K1 b - - 3 20',
        'error_number': 0
      },
      {
        'fen': 'r2q1rk1/3bbppp/p3pn2/1p1pB3/3P4/1QNBP3/PP3PPP/R4RK1 w - - 4 13',
        'error_number': 0
      },
      {
        'fen':
            'rnbqk2r/ppp1bppp/4pn2/3p4/2PP4/2N2N2/PP2PPPP/R1BQKB1R w KQkq - 1 5',
        'error_number': 0
      },
      {
        'fen': '1k1rr3/1p5p/p1Pp2q1/3nppp1/PB6/3P4/3Q1PPP/1R3RK1 b - - 0 28',
        'error_number': 0
      },
      {
        'fen':
            'r3r1k1/3n1pp1/2q1p2p/2p5/p1p2P2/P3P2P/1PQ2BP1/1R2R1K1 w - - 0 27',
        'error_number': 0
      },
      {
        'fen': 'r3rbk1/1R3p1p/3Pq1p1/6B1/p6P/5Q2/5PP1/3R2K1 b - - 3 26',
        'error_number': 0
      },
      {
        'fen':
            'r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3',
        'error_number': 0
      },
      {
        'fen':
            'r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3',
        'error_number': 0
      },
      {
        'fen':
            'r1bqkb1r/1ppp1ppp/p1n2n2/4p3/B3P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 2 5',
        'error_number': 0
      },
      {
        'fen':
            'r1b2rk1/4bppp/p1np4/q3p1P1/1p2P2P/4BP2/PPP1N1Q1/1K1R1B1R w - - 0 17',
        'error_number': 0
      },
      {
        'fen':
            'r2q1rk1/ppp1bppp/2np1nb1/4p3/P1B1P1P1/3P1N1P/1PP2P2/RNBQR1K1 w - - 1 10',
        'error_number': 0
      },
      {
        'fen':
            'r2qkb1r/pb1n1p2/4pP2/1ppP2B1/2p5/2N3P1/PP3P1P/R2QKB1R b KQkq - 0 13',
        'error_number': 0
      },
      {
        'fen': '3k1b1r/p2n1p2/5P2/2pN4/P1p2B2/1p3qP1/1P2KP2/3R4 w - - 0 29',
        'error_number': 0
      },
      {
        'fen':
            'rnbq1rk1/1pp1ppbp/p2p1np1/8/2PPP3/2N1BP2/PP2N1PP/R2QKB1R b KQ - 1 7',
        'error_number': 0
      },
      {
        'fen':
            'rn1qkb1r/pb1p1ppp/1p2pn2/4P3/2Pp4/5NP1/PP1N1PBP/R1BQK2R b KQkq - 0 8',
        'error_number': 0
      },
      {
        'fen':
            'rnbqkbnr/pp1p1ppp/4p3/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 0 3',
        'error_number': 0
      },
      {
        'fen':
            'r1bq1rk1/pp2ppbp/3p1np1/8/3pPP2/3B4/PPPPN1PP/R1BQ1RK1 w - - 4 10',
        'error_number': 0
      },
      {
        'fen': 'r1b3k1/5pbp/2N1p1p1/p6q/2p2P2/2P1B3/PPQ3PP/3R2K1 b - - 0 22',
        'error_number': 0
      },
      {
        'fen': 'rnbqkb1r/ppp1pppp/3p1n2/8/3PP3/8/PPP2PPP/RNBQKBNR w KQkq - 1 3',
        'error_number': 0
      },
      {
        'fen':
            'r1bqkb1r/pppp1ppp/2n2n2/4p3/2PP4/2N2N2/PP2PPPP/R1BQKB1R b KQkq d3 0 4',
        'error_number': 0
      },
      {
        'fen':
            'r1bqk2r/ppp1bppp/2n5/3p4/3Pn3/3B1N2/PPP2PPP/RNBQ1RK1 w kq - 4 8',
        'error_number': 0
      },
      {
        'fen': '4kb1r/1p3pp1/p3p3/4P1BN/1n1p1PPP/PR6/1P4r1/1KR5 b k - 0 24',
        'error_number': 0
      },
      {
        'fen':
            'r3kb1r/pbpp1ppp/1qp1n3/4P3/2P5/1N2Q3/PP1B1PPP/R3KB1R w KQkq - 7 13',
        'error_number': 0
      },
      {
        'fen': 'r1b1r1k1/p4p1p/2pb2p1/3pn3/N7/4BP2/PPP2KPP/3RRB2 b - - 3 18',
        'error_number': 0
      },
      {
        'fen': 'r1b2rk1/p2nqp1p/3P2p1/2p2p2/2B5/1PB3N1/P4PPP/R2Q2K1 b - - 0 18',
        'error_number': 0
      },
      {
        'fen':
            'rnb1k2r/1p3ppp/p3Pn2/8/3N2P1/2q1B3/P1P1BP1P/R2Q1K1R b kq - 1 12',
        'error_number': 0
      },
      {
        'fen':
            'rnb1k2r/1pq1bppp/p2ppn2/8/3NPP2/2N1B3/PPP1B1PP/R2QK2R w KQkq - 1 9',
        'error_number': 0
      },
      {
        'fen': 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1',
        'error_number': 0
      },
      {
        'fen': '4r3/1pr3pk/p2p2q1/3Pppbp/8/1NPQ1PP1/PP2R2P/1K1R4 w - - 8 28',
        'error_number': 0
      },
      {
        'fen': 'b2r3r/4kp2/p3p1p1/1p2P3/1P1n1P2/P1NB4/KP4P1/3R2R1 b - - 2 26',
        'error_number': 0
      },
      {
        'fen':
            'rnbqk2r/ppppppbp/5np1/8/2PPP3/2N5/PP3PPP/R1BQKBNR b KQkq e3 0 4',
        'error_number': 0
      },
      {
        'fen': 'rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2',
        'error_number': 0
      },
      {
        'fen':
            'rn1q1rk1/pbp2pp1/1p3b1p/3p4/3P4/2NBPN2/PP3PPP/2RQK2R b K - 1 11',
        'error_number': 0
      },
      {
        'fen':
            '2rq1rk1/pp1bppbp/3p1np1/8/2BNP3/2N1BP2/PPPQ2PP/1K1R3R b - - 0 13',
        'error_number': 0
      },
      {
        'fen':
            'r2qkb1r/1p1bpppp/p1np4/6B1/B3P1n1/2PQ1N2/PP3PPP/RN2R1K1 b kq - 0 10',
        'error_number': 0
      },
      {
        'fen': 'r1bq1rk1/1p2npb1/p6p/3p2p1/3P3B/2N5/PP2BPPP/R2QR1K1 w - - 0 15',
        'error_number': 0
      },
      {
        'fen':
            'r3r1k1/pbq1bppp/4pnn1/2p1B1N1/2P2P2/1P1B2N1/P3Q1PP/4RRK1 b - - 4 17',
        'error_number': 0
      },
      {
        'fen': '4k3/5p2/p1q1pbp1/1pr1P3/3n1P2/1B2B2Q/PP3P2/3R3K w - - 1 28',
        'error_number': 0
      },
      {
        'fen': '2k4r/pp1r1p1p/8/2Pq1p2/1Pn2P2/PQ3NP1/3p1NKP/R7 b - - 0 28',
        'error_number': 0
      },
      {
        'fen':
            'rnbqkb1r/ppp2ppp/3p1n2/4N3/4P3/8/PPPP1PPP/RNBQKB1R w KQkq - 0 4',
        'error_number': 0
      },
      {
        'fen': '3r1rk1/Qpp2p1p/7q/1P2P1p1/2B1Rn2/6NP/P4P1P/5RK1 b - - 0 22',
        'error_number': 0
      },
      {
        'fen':
            'rn2kb1r/2qp1ppp/b3pn2/2pP2B1/1pN1P3/5P2/PP4PP/R2QKBNR w KQkq - 4 11',
        'error_number': 0
      },
      {
        'fen':
            'r3k2r/pp1nbp1p/2p2pb1/3p4/3P3N/2N1P3/PP3PPP/R3KB1R w KQkq - 4 12',
        'error_number': 0
      },
      {
        'fen':
            'rn1qr1k1/pbppbppp/1p3n2/3P4/8/P1N1P1P1/1P2NPBP/R1BQK2R b KQ - 2 10',
        'error_number': 0
      },
      {
        'fen':
            'r1bqk2r/pp1nbppp/2p2n2/3p2B1/3P4/2N1PN2/PP3PPP/R2QKB1R w KQkq - 1 8',
        'error_number': 0
      },
      {
        'fen':
            'r1bqk2r/pppp1pp1/2n2n1p/8/1bPN3B/2N5/PP2PPPP/R2QKB1R b KQkq - 1 7',
        'error_number': 0
      },
      {
        'fen':
            'r1bqk2r/1pppbppp/p1n2n2/4p3/B3P3/5N2/PPPP1PPP/RNBQ1RK1 w kq - 4 6',
        'error_number': 0
      },
      {
        'fen':
            'r1b1kb1r/p2p1ppp/1qp1p3/3nP3/2P1NP2/8/PP4PP/R1BQKB1R b KQkq c3 0 10',
        'error_number': 0
      },
      {'fen': '8/R7/2b5/3k2K1/P1p1r3/2B5/1P6/8 b - - 8 74', 'error_number': 0},
      {
        'fen': '2q5/5pk1/5p1p/4b3/1p1pP3/7P/1Pr3P1/R2Q1RK1 w - - 14 37',
        'error_number': 0
      },
      {
        'fen': 'r4rk1/1bqnbppp/p2p4/1p2p3/3BPP2/P1NB4/1PP3PP/3RQR1K w - - 0 16',
        'error_number': 0
      },
      {
        'fen':
            'r1bqk2r/pp1n1ppp/2pbpn2/6N1/3P4/3B1N2/PPP2PPP/R1BQK2R w KQkq - 2 8',
        'error_number': 0
      },
      {
        'fen':
            'r1b1kb1r/pp3ppp/1qnppn2/8/2B1PB2/1NN5/PPP2PPP/R2QK2R b KQkq - 1 8',
        'error_number': 0
      },
      {
        'fen': '1r3r1k/2q1n1pb/pn5p/1p2pP2/6B1/PPNRQ2P/2P1N1P1/3R3K b - - 0 28',
        'error_number': 0
      },
      {
        'fen':
            'rnbqk2r/ppp1bppp/4pn2/3p2B1/2PP4/2N2N2/PP2PPPP/R2QKB1R b KQkq - 3 5',
        'error_number': 0
      },
      {
        'fen': '2r3k1/5pp1/p2p3p/1p1Pp2P/5b2/8/qP1K2P1/3QRB1R w - - 0 26',
        'error_number': 0
      },
      {
        'fen': '6k1/1Q3p2/2p1r3/B1Pn2p1/3P1b1p/5P1P/5P2/5K2 w - - 6 47',
        'error_number': 0
      },
      {
        'fen': '8/k7/Pr2R3/7p/8/4n1P1/1r2p1P1/4R1K1 w - - 0 59',
        'error_number': 0
      },
      {
        'fen': '8/3k4/1nbPp2p/1pK2np1/p7/PP1R1P2/2P4P/4R3 b - - 7 34',
        'error_number': 0
      },
      {
        'fen': '4rbk1/rnR2p1p/pp2pnp1/3p4/3P4/1P2PB1P/P2BNPP1/R5K1 b - - 0 20',
        'error_number': 0
      },
      {
        'fen': '5r2/6pk/8/p3P1p1/1R6/7Q/1Pr2P1K/2q5 b - - 2 48',
        'error_number': 0
      },
      {
        'fen':
            '1br2rk1/2q2pp1/p3bnp1/1p1p4/8/1PN1PBPP/PB1Q1P2/R2R2K1 b - - 0 19',
        'error_number': 0
      },
      {
        'fen': '4r1k1/b4p2/p4pp1/1p6/3p1N1P/1P2P1P1/P4P2/3R2K1 w - - 0 30',
        'error_number': 0
      },
      {
        'fen': '3rk3/1Q4p1/p3p3/4RPqp/4p2P/P7/KPP5/8 b - h3 0 33',
        'error_number': 0
      },
      {
        'fen': '6k1/1p1r1pp1/5qp1/p1pBP3/Pb3n2/1Q1RB2P/1P3PP1/6K1 b - - 0 28',
        'error_number': 0
      },
      {
        'fen': '3r2k1/pp2bp2/1q4p1/3p1b1p/4PB1P/2P2PQ1/P2R2P1/3R2K1 w - - 1 28',
        'error_number': 0
      },
      {
        'fen': '3r4/p1qn1pk1/1p1R3p/2P1pQpP/8/4B3/5PP1/6K1 w - - 0 35',
        'error_number': 0
      },
      {
        'fen':
            'rnb1k1nr/pp2q1pp/2pp4/4pp2/2PPP3/8/PP2NPPP/R1BQKB1R w KQkq f6 0 8',
        'error_number': 0
      },
      {
        'fen': 'rnbqkbnr/pp1ppppp/2p5/8/3PP3/8/PPP2PPP/RNBQKBNR b KQkq d3 0 2',
        'error_number': 0
      },
      {
        'fen': '4q1k1/6p1/p2rnpPp/1p2p3/7P/1BP5/PP3Q2/1K3R2 w - - 0 34',
        'error_number': 0
      },
      {
        'fen':
            '3r2k1/p1q2pp1/1n2rn1p/1B2p3/P1p1P3/2P3BP/4QPP1/1R2R1K1 b - - 1 25',
        'error_number': 0
      },
      {'fen': '8/p7/1b2BkR1/5P2/4K3/7r/P7/8 b - - 9 52', 'error_number': 0},
      {
        'fen': '2rq2k1/p4p1p/1p1prp2/1Ppb4/8/P1QPP1P1/1B3P1P/R3R1K1 w - - 2 20',
        'error_number': 0
      },
      {
        'fen': '8/1pQ3bk/p2p1qp1/P2Pp2p/NP6/7P/5PP1/6K1 w - - 1 36',
        'error_number': 0
      },
      {
        'fen': '8/1pQ3bk/p2p2p1/P2Pp2p/1P5P/2N3P1/2q2PK1/8 b - - 0 39',
        'error_number': 0
      },
      {
        'fen':
            'r1bq1rk1/pp2n1bp/2pp1np1/3PppN1/1PP1P3/2N2B2/P4PPP/R1BQR1K1 w - - 0 13',
        'error_number': 0
      },
      {
        'fen': '1r4k1/5p2/3P2pp/p3Pp2/5q2/2Q2P1P/5P2/4R1K1 w - - 0 29',
        'error_number': 0
      },
      {
        'fen': 'rnbqkbnr/pp2pppp/3p4/8/3pP3/5N2/PPP2PPP/RNBQKB1R w KQkq - 0 4',
        'error_number': 0
      },
      {
        'fen':
            'R2qk2r/2p2ppp/1bnp1n2/1p2p3/3PP1b1/1BP2N2/1P3PPP/1NBQ1RK1 b k - 0 11',
        'error_number': 0
      },
      {
        'fen': '6k1/4qp2/3p2p1/3Pp2p/7P/4Q1P1/5PBK/8 b - - 20 57',
        'error_number': 0
      },
      {
        'fen': '3k4/r3q3/3p1p2/2pB4/P7/7P/6P1/1Q4K1 b - - 6 43',
        'error_number': 0
      },
      {
        'fen': '5k2/1n4p1/2p2p2/p2q1B1P/P4PK1/6P1/1Q6/8 b - - 4 46',
        'error_number': 0
      },
      {
        'fen': '6k1/pr2pb2/5pp1/1B1p4/P7/4QP2/1PP3Pq/2KR4 w - - 1 27',
        'error_number': 0
      },
      {
        'fen':
            '1rbqk2r/2pp1ppp/2n2n2/1pb1p3/4P3/1BP2N2/1P1P1PPP/RNBQ1RK1 b k - 0 9',
        'error_number': 0
      },
      {
        'fen': '6r1/2p5/pbpp1k1r/5b2/3P1N1p/1PP2N1P/P4R2/2K1R3 w - - 4 33',
        'error_number': 0
      },
      {
        'fen': 'rnbqkb1r/pppppppp/5n2/8/3P4/5N2/PPP1PPPP/RNBQKB1R b KQkq - 2 2',
        'error_number': 0
      },
      {
        'fen': 'rnbqkb1r/pppppppp/5n2/8/2PP4/8/PP2PPPP/RNBQKBNR b KQkq c3 0 2',
        'error_number': 0
      },
      {
        'fen': '4b3/5p1k/r7/p3BNQp/4P1pP/1r1n4/1P3P1N/7K b - - 2 40',
        'error_number': 0
      },
      {
        'fen':
            'r2q1rk1/pb1p2pp/1p1bpnn1/5p2/2PP4/PPN1BP1P/2B1N1P1/1R1Q1R1K b - - 2 16',
        'error_number': 0
      },
      {
        'fen': 'rnbqkbnr/ppp1pppp/8/8/2pP4/5N2/PP2PPPP/RNBQKB1R b KQkq - 1 3',
        'error_number': 0
      },
      {
        'fen': '4rrk1/8/p1pR4/1p6/1PPKNq2/3P1p2/PB5n/R2Q4 b - - 6 40',
        'error_number': 0
      },
      {
        'fen':
            'r1bqk1nr/1p2bppp/p1np4/4p3/2P1P3/N1N5/PP3PPP/R1BQKB1R b KQkq - 1 8',
        'error_number': 0
      },
      {
        'fen':
            'r1bqk2r/pp2bppp/2n1p3/3n4/3P4/2NB1N2/PP3PPP/R1BQ1RK1 b kq - 3 9',
        'error_number': 0
      },
      {
        'fen':
            'r1bqkbnr/pppp2pp/2n5/1B2p3/3Pp3/5N2/PPP2PPP/RNBQK2R w KQkq - 0 5',
        'error_number': 0
      },
      {
        'fen': '2n1r3/p1k2pp1/B1p3b1/P7/5bP1/2N1B3/1P2KP2/2R5 b - - 4 25',
        'error_number': 0
      },
      {
        'fen': 'r4rk1/2q3pp/4p3/p1Pn1p2/1p1P4/4PP2/1B1Q2PP/R3R1K1 w - - 0 22',
        'error_number': 0
      },
      {'fen': '8/8/1p6/3b4/1P1k1p2/8/3KBP2/8 w - - 2 68', 'error_number': 0},
      {
        'fen': '2b2k2/1p5p/2p5/p1p1q3/2PbN3/1P5P/P5B1/3RR2K w - - 4 33',
        'error_number': 0
      },
      {
        'fen': '1b6/5kp1/5p2/1b1p4/1P6/4PPq1/2Q2RNp/7K b - - 2 41',
        'error_number': 0
      },
      {
        'fen':
            'r3r1k1/p2nqpp1/bpp2n1p/3p4/B2P4/P1Q1PP2/1P2NBPP/R3K2R w KQ - 6 16',
        'error_number': 0
      },
      {
        'fen': 'r3k2r/8/p4p2/3p2p1/4b3/2R2PP1/P6P/4R1K1 b kq - 0 27',
        'error_number': 0
      },
      {
        'fen': 'r1rb2k1/5ppp/pqp5/3pPb2/QB1P4/2R2N2/P4PPP/2R3K1 b - - 7 23',
        'error_number': 0
      },
      {
        'fen': '3r1r2/3P2pk/1p1R3p/1Bp2p2/6q1/4Q3/PP3P1P/7K w - - 4 30',
        'error_number': 0
      },
    ];

    positions.forEach((position) {
      test(
          position['fen'] +
              ' (valid: ' +
              (position['error_number'] == 0).toString() +
              ')', () {
        var result = Chess.validate_fen(position['fen']);
        expect(result['error_number'], equals(position['error_number']));
      });
    });
  });

  group('History', () {
    final chess = Chess();
    const tests = <Map<String, dynamic>>[
      {
        'verbose': false,
        'fen': '4q2k/2r1r3/4PR1p/p1p5/P1Bp1Q1P/1P6/6P1/6K1 b - - 4 41',
        'moves': [
          'c4',
          'e6',
          'Nf3',
          'd5',
          'd4',
          'Nf6',
          'Nc3',
          'Be7',
          'Bg5',
          'O-O',
          'e3',
          'h6',
          'Bh4',
          'b6',
          'cxd5',
          'Nxd5',
          'Bxe7',
          'Qxe7',
          'Nxd5',
          'exd5',
          'Rc1',
          'Be6',
          'Qa4',
          'c5',
          'Qa3',
          'Rc8',
          'Bb5',
          'a6',
          'dxc5',
          'bxc5',
          'O-O',
          'Ra7',
          'Be2',
          'Nd7',
          'Nd4',
          'Qf8',
          'Nxe6',
          'fxe6',
          'e4',
          'd4',
          'f4',
          'Qe7',
          'e5',
          'Rb8',
          'Bc4',
          'Kh8',
          'Qh3',
          'Nf8',
          'b3',
          'a5',
          'f5',
          'exf5',
          'Rxf5',
          'Nh7',
          'Rcf1',
          'Qd8',
          'Qg3',
          'Re7',
          'h4',
          'Rbb7',
          'e6',
          'Rbc7',
          'Qe5',
          'Qe8',
          'a4',
          'Qd8',
          'R1f2',
          'Qe8',
          'R2f3',
          'Qd8',
          'Bd3',
          'Qe8',
          'Qe4',
          'Nf6',
          'Rxf6',
          'gxf6',
          'Rxf6',
          'Kg8',
          'Bc4',
          'Kh8',
          'Qf4'
        ]
      },
      {
        'verbose': true,
        'fen': '4q2k/2r1r3/4PR1p/p1p5/P1Bp1Q1P/1P6/6P1/6K1 b - - 4 41',
        'moves': [
          {
            'color': Chess.WHITE,
            'from': 'c2',
            'to': 'c4',
            'flags': 'b',
            'piece': Chess.PAWN,
            'san': 'c4'
          },
          {
            'color': Chess.BLACK,
            'from': 'e7',
            'to': 'e6',
            'flags': 'n',
            'piece': Chess.PAWN,
            'san': 'e6'
          },
          {
            'color': Chess.WHITE,
            'from': 'g1',
            'to': 'f3',
            'flags': 'n',
            'piece': Chess.KNIGHT,
            'san': 'Nf3'
          },
          {
            'color': Chess.BLACK,
            'from': 'd7',
            'to': 'd5',
            'flags': 'b',
            'piece': Chess.PAWN,
            'san': 'd5'
          },
          {
            'color': Chess.WHITE,
            'from': 'd2',
            'to': 'd4',
            'flags': 'b',
            'piece': Chess.PAWN,
            'san': 'd4'
          },
          {
            'color': Chess.BLACK,
            'from': 'g8',
            'to': 'f6',
            'flags': 'n',
            'piece': Chess.KNIGHT,
            'san': 'Nf6'
          },
          {
            'color': Chess.WHITE,
            'from': 'b1',
            'to': 'c3',
            'flags': 'n',
            'piece': Chess.KNIGHT,
            'san': 'Nc3'
          },
          {
            'color': Chess.BLACK,
            'from': 'f8',
            'to': 'e7',
            'flags': 'n',
            'piece': Chess.BISHOP,
            'san': 'Be7'
          },
          {
            'color': Chess.WHITE,
            'from': 'c1',
            'to': 'g5',
            'flags': 'n',
            'piece': Chess.BISHOP,
            'san': 'Bg5'
          },
          {
            'color': Chess.BLACK,
            'from': 'e8',
            'to': 'g8',
            'flags': 'k',
            'piece': Chess.KING,
            'san': 'O-O'
          },
          {
            'color': Chess.WHITE,
            'from': 'e2',
            'to': 'e3',
            'flags': 'n',
            'piece': Chess.PAWN,
            'san': 'e3'
          },
          {
            'color': Chess.BLACK,
            'from': 'h7',
            'to': 'h6',
            'flags': 'n',
            'piece': Chess.PAWN,
            'san': 'h6'
          },
          {
            'color': Chess.WHITE,
            'from': 'g5',
            'to': 'h4',
            'flags': 'n',
            'piece': Chess.BISHOP,
            'san': 'Bh4'
          },
          {
            'color': Chess.BLACK,
            'from': 'b7',
            'to': 'b6',
            'flags': 'n',
            'piece': Chess.PAWN,
            'san': 'b6'
          },
          {
            'color': Chess.WHITE,
            'from': 'c4',
            'to': 'd5',
            'flags': 'c',
            'piece': Chess.PAWN,
            'captured': Chess.PAWN,
            'san': 'cxd5'
          },
          {
            'color': Chess.BLACK,
            'from': 'f6',
            'to': 'd5',
            'flags': 'c',
            'piece': Chess.KNIGHT,
            'captured': Chess.PAWN,
            'san': 'Nxd5'
          },
          {
            'color': Chess.WHITE,
            'from': 'h4',
            'to': 'e7',
            'flags': 'c',
            'piece': Chess.BISHOP,
            'captured': Chess.BISHOP,
            'san': 'Bxe7'
          },
          {
            'color': Chess.BLACK,
            'from': 'd8',
            'to': 'e7',
            'flags': 'c',
            'piece': Chess.QUEEN,
            'captured': Chess.BISHOP,
            'san': 'Qxe7'
          },
          {
            'color': Chess.WHITE,
            'from': 'c3',
            'to': 'd5',
            'flags': 'c',
            'piece': Chess.KNIGHT,
            'captured': Chess.KNIGHT,
            'san': 'Nxd5'
          },
          {
            'color': Chess.BLACK,
            'from': 'e6',
            'to': 'd5',
            'flags': 'c',
            'piece': Chess.PAWN,
            'captured': Chess.KNIGHT,
            'san': 'exd5'
          },
          {
            'color': Chess.WHITE,
            'from': 'a1',
            'to': 'c1',
            'flags': 'n',
            'piece': Chess.ROOK,
            'san': 'Rc1'
          },
          {
            'color': Chess.BLACK,
            'from': 'c8',
            'to': 'e6',
            'flags': 'n',
            'piece': Chess.BISHOP,
            'san': 'Be6'
          },
          {
            'color': Chess.WHITE,
            'from': 'd1',
            'to': 'a4',
            'flags': 'n',
            'piece': Chess.QUEEN,
            'san': 'Qa4'
          },
          {
            'color': Chess.BLACK,
            'from': 'c7',
            'to': 'c5',
            'flags': 'b',
            'piece': Chess.PAWN,
            'san': 'c5'
          },
          {
            'color': Chess.WHITE,
            'from': 'a4',
            'to': 'a3',
            'flags': 'n',
            'piece': Chess.QUEEN,
            'san': 'Qa3'
          },
          {
            'color': Chess.BLACK,
            'from': 'f8',
            'to': 'c8',
            'flags': 'n',
            'piece': Chess.ROOK,
            'san': 'Rc8'
          },
          {
            'color': Chess.WHITE,
            'from': 'f1',
            'to': 'b5',
            'flags': 'n',
            'piece': Chess.BISHOP,
            'san': 'Bb5'
          },
          {
            'color': Chess.BLACK,
            'from': 'a7',
            'to': 'a6',
            'flags': 'n',
            'piece': Chess.PAWN,
            'san': 'a6'
          },
          {
            'color': Chess.WHITE,
            'from': 'd4',
            'to': 'c5',
            'flags': 'c',
            'piece': Chess.PAWN,
            'captured': Chess.PAWN,
            'san': 'dxc5'
          },
          {
            'color': Chess.BLACK,
            'from': 'b6',
            'to': 'c5',
            'flags': 'c',
            'piece': Chess.PAWN,
            'captured': Chess.PAWN,
            'san': 'bxc5'
          },
          {
            'color': Chess.WHITE,
            'from': 'e1',
            'to': 'g1',
            'flags': 'k',
            'piece': Chess.KING,
            'san': 'O-O'
          },
          {
            'color': Chess.BLACK,
            'from': 'a8',
            'to': 'a7',
            'flags': 'n',
            'piece': Chess.ROOK,
            'san': 'Ra7'
          },
          {
            'color': Chess.WHITE,
            'from': 'b5',
            'to': 'e2',
            'flags': 'n',
            'piece': Chess.BISHOP,
            'san': 'Be2'
          },
          {
            'color': Chess.BLACK,
            'from': 'b8',
            'to': 'd7',
            'flags': 'n',
            'piece': Chess.KNIGHT,
            'san': 'Nd7'
          },
          {
            'color': Chess.WHITE,
            'from': 'f3',
            'to': 'd4',
            'flags': 'n',
            'piece': Chess.KNIGHT,
            'san': 'Nd4'
          },
          {
            'color': Chess.BLACK,
            'from': 'e7',
            'to': 'f8',
            'flags': 'n',
            'piece': Chess.QUEEN,
            'san': 'Qf8'
          },
          {
            'color': Chess.WHITE,
            'from': 'd4',
            'to': 'e6',
            'flags': 'c',
            'piece': Chess.KNIGHT,
            'captured': Chess.BISHOP,
            'san': 'Nxe6'
          },
          {
            'color': Chess.BLACK,
            'from': 'f7',
            'to': 'e6',
            'flags': 'c',
            'piece': Chess.PAWN,
            'captured': Chess.KNIGHT,
            'san': 'fxe6'
          },
          {
            'color': Chess.WHITE,
            'from': 'e3',
            'to': 'e4',
            'flags': 'n',
            'piece': Chess.PAWN,
            'san': 'e4'
          },
          {
            'color': Chess.BLACK,
            'from': 'd5',
            'to': 'd4',
            'flags': 'n',
            'piece': Chess.PAWN,
            'san': 'd4'
          },
          {
            'color': Chess.WHITE,
            'from': 'f2',
            'to': 'f4',
            'flags': 'b',
            'piece': Chess.PAWN,
            'san': 'f4'
          },
          {
            'color': Chess.BLACK,
            'from': 'f8',
            'to': 'e7',
            'flags': 'n',
            'piece': Chess.QUEEN,
            'san': 'Qe7'
          },
          {
            'color': Chess.WHITE,
            'from': 'e4',
            'to': 'e5',
            'flags': 'n',
            'piece': Chess.PAWN,
            'san': 'e5'
          },
          {
            'color': Chess.BLACK,
            'from': 'c8',
            'to': 'b8',
            'flags': 'n',
            'piece': Chess.ROOK,
            'san': 'Rb8'
          },
          {
            'color': Chess.WHITE,
            'from': 'e2',
            'to': 'c4',
            'flags': 'n',
            'piece': Chess.BISHOP,
            'san': 'Bc4'
          },
          {
            'color': Chess.BLACK,
            'from': 'g8',
            'to': 'h8',
            'flags': 'n',
            'piece': Chess.KING,
            'san': 'Kh8'
          },
          {
            'color': Chess.WHITE,
            'from': 'a3',
            'to': 'h3',
            'flags': 'n',
            'piece': Chess.QUEEN,
            'san': 'Qh3'
          },
          {
            'color': Chess.BLACK,
            'from': 'd7',
            'to': 'f8',
            'flags': 'n',
            'piece': Chess.KNIGHT,
            'san': 'Nf8'
          },
          {
            'color': Chess.WHITE,
            'from': 'b2',
            'to': 'b3',
            'flags': 'n',
            'piece': Chess.PAWN,
            'san': 'b3'
          },
          {
            'color': Chess.BLACK,
            'from': 'a6',
            'to': 'a5',
            'flags': 'n',
            'piece': Chess.PAWN,
            'san': 'a5'
          },
          {
            'color': Chess.WHITE,
            'from': 'f4',
            'to': 'f5',
            'flags': 'n',
            'piece': Chess.PAWN,
            'san': 'f5'
          },
          {
            'color': Chess.BLACK,
            'from': 'e6',
            'to': 'f5',
            'flags': 'c',
            'piece': Chess.PAWN,
            'captured': Chess.PAWN,
            'san': 'exf5'
          },
          {
            'color': Chess.WHITE,
            'from': 'f1',
            'to': 'f5',
            'flags': 'c',
            'piece': Chess.ROOK,
            'captured': Chess.PAWN,
            'san': 'Rxf5'
          },
          {
            'color': Chess.BLACK,
            'from': 'f8',
            'to': 'h7',
            'flags': 'n',
            'piece': Chess.KNIGHT,
            'san': 'Nh7'
          },
          {
            'color': Chess.WHITE,
            'from': 'c1',
            'to': 'f1',
            'flags': 'n',
            'piece': Chess.ROOK,
            'san': 'Rcf1'
          },
          {
            'color': Chess.BLACK,
            'from': 'e7',
            'to': 'd8',
            'flags': 'n',
            'piece': Chess.QUEEN,
            'san': 'Qd8'
          },
          {
            'color': Chess.WHITE,
            'from': 'h3',
            'to': 'g3',
            'flags': 'n',
            'piece': Chess.QUEEN,
            'san': 'Qg3'
          },
          {
            'color': Chess.BLACK,
            'from': 'a7',
            'to': 'e7',
            'flags': 'n',
            'piece': Chess.ROOK,
            'san': 'Re7'
          },
          {
            'color': Chess.WHITE,
            'from': 'h2',
            'to': 'h4',
            'flags': 'b',
            'piece': Chess.PAWN,
            'san': 'h4'
          },
          {
            'color': Chess.BLACK,
            'from': 'b8',
            'to': 'b7',
            'flags': 'n',
            'piece': Chess.ROOK,
            'san': 'Rbb7'
          },
          {
            'color': Chess.WHITE,
            'from': 'e5',
            'to': 'e6',
            'flags': 'n',
            'piece': Chess.PAWN,
            'san': 'e6'
          },
          {
            'color': Chess.BLACK,
            'from': 'b7',
            'to': 'c7',
            'flags': 'n',
            'piece': Chess.ROOK,
            'san': 'Rbc7'
          },
          {
            'color': Chess.WHITE,
            'from': 'g3',
            'to': 'e5',
            'flags': 'n',
            'piece': Chess.QUEEN,
            'san': 'Qe5'
          },
          {
            'color': Chess.BLACK,
            'from': 'd8',
            'to': 'e8',
            'flags': 'n',
            'piece': Chess.QUEEN,
            'san': 'Qe8'
          },
          {
            'color': Chess.WHITE,
            'from': 'a2',
            'to': 'a4',
            'flags': 'b',
            'piece': Chess.PAWN,
            'san': 'a4'
          },
          {
            'color': Chess.BLACK,
            'from': 'e8',
            'to': 'd8',
            'flags': 'n',
            'piece': Chess.QUEEN,
            'san': 'Qd8'
          },
          {
            'color': Chess.WHITE,
            'from': 'f1',
            'to': 'f2',
            'flags': 'n',
            'piece': Chess.ROOK,
            'san': 'R1f2'
          },
          {
            'color': Chess.BLACK,
            'from': 'd8',
            'to': 'e8',
            'flags': 'n',
            'piece': Chess.QUEEN,
            'san': 'Qe8'
          },
          {
            'color': Chess.WHITE,
            'from': 'f2',
            'to': 'f3',
            'flags': 'n',
            'piece': Chess.ROOK,
            'san': 'R2f3'
          },
          {
            'color': Chess.BLACK,
            'from': 'e8',
            'to': 'd8',
            'flags': 'n',
            'piece': Chess.QUEEN,
            'san': 'Qd8'
          },
          {
            'color': Chess.WHITE,
            'from': 'c4',
            'to': 'd3',
            'flags': 'n',
            'piece': Chess.BISHOP,
            'san': 'Bd3'
          },
          {
            'color': Chess.BLACK,
            'from': 'd8',
            'to': 'e8',
            'flags': 'n',
            'piece': Chess.QUEEN,
            'san': 'Qe8'
          },
          {
            'color': Chess.WHITE,
            'from': 'e5',
            'to': 'e4',
            'flags': 'n',
            'piece': Chess.QUEEN,
            'san': 'Qe4'
          },
          {
            'color': Chess.BLACK,
            'from': 'h7',
            'to': 'f6',
            'flags': 'n',
            'piece': Chess.KNIGHT,
            'san': 'Nf6'
          },
          {
            'color': Chess.WHITE,
            'from': 'f5',
            'to': 'f6',
            'flags': 'c',
            'piece': Chess.ROOK,
            'captured': Chess.KNIGHT,
            'san': 'Rxf6'
          },
          {
            'color': Chess.BLACK,
            'from': 'g7',
            'to': 'f6',
            'flags': 'c',
            'piece': Chess.PAWN,
            'captured': Chess.ROOK,
            'san': 'gxf6'
          },
          {
            'color': Chess.WHITE,
            'from': 'f3',
            'to': 'f6',
            'flags': 'c',
            'piece': Chess.ROOK,
            'captured': Chess.PAWN,
            'san': 'Rxf6'
          },
          {
            'color': Chess.BLACK,
            'from': 'h8',
            'to': 'g8',
            'flags': 'n',
            'piece': Chess.KING,
            'san': 'Kg8'
          },
          {
            'color': Chess.WHITE,
            'from': 'd3',
            'to': 'c4',
            'flags': 'n',
            'piece': Chess.BISHOP,
            'san': 'Bc4'
          },
          {
            'color': Chess.BLACK,
            'from': 'g8',
            'to': 'h8',
            'flags': 'n',
            'piece': Chess.KING,
            'san': 'Kh8'
          },
          {
            'color': Chess.WHITE,
            'from': 'e4',
            'to': 'f4',
            'flags': 'n',
            'piece': Chess.QUEEN,
            'san': 'Qf4'
          }
        ],
      }
    ];

    tests.forEach((t) {
      var passed = true;

      test(t['fen'], () {
        chess.reset();

        for (var j = 0; j < t['moves'].length; j++) {
          chess.move(t['moves'][j]);
        }

        var history = chess.getHistory({'verbose': t['verbose']});
        if (t['fen'] != chess.fen) {
          passed = false;
        } else if (history.length != t['moves'].length) {
          passed = false;
        } else {
          for (var j = 0; j < t['moves'].length; j++) {
            if (!t['verbose']) {
              if (history[j] != t['moves'][j]) {
                passed = false;
                break;
              }
            } else {
              for (var key in history[j].keys) {
                if (history[j][key] != t['moves'][j][key]) {
                  passed = false;
                  break;
                }
              }
            }
          }
        }
        expect(passed, isTrue);
      });
    });
  });

  group('Regression Tests', () {
    // Github Issue #32 reported by AlgoTrader
    test('Issue #32 - castling flag reappearing', () {
      final chess =
          Chess.fromFEN('b3k2r/5p2/4p3/1p5p/6p1/2PR2P1/BP3qNP/6QK b k - 2 28');
      chess.move({'from': 'a8', 'to': 'g2'});
      expect(chess.fen,
          equals('4k2r/5p2/4p3/1p5p/6p1/2PR2P1/BP3qbP/6QK w k - 0 29'));
    });
  });
}
