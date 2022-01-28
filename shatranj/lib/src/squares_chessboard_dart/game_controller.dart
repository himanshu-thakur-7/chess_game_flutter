import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bishop/bishop.dart' as bishop;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:squares/squares.dart';
import 'package:bishop/src/move.dart' as M;

import 'square_chess_board.dart';

bishop.Game? game;
GameState? gs;
int? lf;
int? lt;
int? ck;
bool? playable;
GlobalKey<ChessBoardState> gkc = GlobalKey();

class GameController extends Cubit<GameState> {
  int pc = WHITE;
  GameController() : super(GameState.initial());
  bishop.Engine? engine;
  bool vsEngine = false;
  // keeping counter of number of a times a position appears on board
  Map<String, int> fenCounter = {
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq': 1
  };

  checkSq() {
    return game!.info.checkSq;
  }

  void emitState([bool thinking = false]) {
    if (game == null) {
      emit(GameState.initial());
    }
    BoardSize size = BoardSize(game!.size.h, game!.size.v);
    bool canMove = game!.turn == pc;
    if (!vsEngine) {
      canMove = false;
    }

    List<M.Move> _moves = game!.generateLegalMoves();
    List<Move> moves = [];
    for (bishop.Move move in _moves) {
      String algebraic = game!.toAlgebraic(move);
      Move _move = moveFromAlgebraic(algebraic, size);
      moves.add(_move);
    }
    bishop.GameInfo gameInfo = game!.info;
    BoardState board = BoardState(
      board: game!.boardSymbols(),
      player: pc,
      orientation: pc,
      lastFrom: gameInfo.lastFrom != null
          ? size.squareNumber(gameInfo.lastFrom!)
          : null,
      lastTo:
          gameInfo.lastTo != null ? size.squareNumber(gameInfo.lastTo!) : null,
      checkSquare: gameInfo.checkSq != null
          ? size.squareNumber(gameInfo.checkSq!)
          : null,
    );
    PlayState state = game!.gameOver
        ? PlayState.finished
        : (canMove ? PlayState.ourTurn : PlayState.theirTurn);

    gs = GameState(
      state: state,
      thinking: thinking,
      size: size,
      board: board,
      moves: moves,
      hands: game!.handSymbols(),
    );
    emit(gs!);
  }

  getGameState() {
    return gs;
  }

  getFen() {
    return game!.fen;
  }

// loading a fen
  loadFen(fen) {
    String old = game!.fen;

    game!.loadFen(fen);

    String newFen = game!.fen;

    game = bishop.Game(variant: bishop.Variant.standard(), fen: fen);
    emitState();
  }

// check if game is not initialized
  isGameNull() {
    return game == null;
  }

// start the game
  void startGame(
      {String? fen, required bool vsEngine, required int playerColor}) {
    pc = playerColor;

    game = bishop.Game(variant: bishop.Variant.standard(), fen: fen);

    engine = bishop.Engine(game: game!);
    this.vsEngine = vsEngine;
    emitState();
  }

// make a move in vs comp mode:
  void makeMove(Move move, {String? fen, bool? vsEngine, ChessBoard? widget}) {
    if (game == null) {
      return;
    }

    String alg = moveToAlgebraic(move, state.size);

    bishop.Move? m = game!.getMove(alg);
    if (m == null)
      print('move $alg not found');
    else {
      game!.makeMove(m);
      print(game!.fen);
      String fen = game!.fen.split(" -")[0].trim();
      print(fen);
      if (fenCounter[fen] == null) {
        fenCounter[fen] = 0;
      }
      fenCounter[fen] = fenCounter[fen]! + 1;
      print("counter: ${fenCounter[fen]}");

      emitState();

      if (vsEngine!) {
        Future.delayed(Duration(milliseconds: 200))
            .then((_) => engineMove(widget));
      }
    }
  }

// make move in online mode
  void makeMovePlayer(data) {
    game!.loadFen(data["fen"]);

    print(game!.fen);
    String fen = game!.fen.split(" -")[0].trim();
    print(fen);
    if (fenCounter[fen] == null) {
      fenCounter[fen] = 0;
    }
    fenCounter[fen] = fenCounter[fen]! + 1;
    print("counter: ${fenCounter[fen]}");

    BoardSize size = BoardSize(game!.size.h, game!.size.v);
    bool canMove = game!.turn != pc;
    List<M.Move> _legalmoves = game!.generateLegalMoves();
    List<Move> moves = [];
    for (bishop.Move move in _legalmoves) {
      String algebraic = game!.toAlgebraic(move);
      Move _move = moveFromAlgebraic(algebraic, size);
      moves.add(_move);
    }
    bishop.GameInfo gameInfo = game!.info;
    BoardState board = BoardState(
      board: game!.boardSymbols(),
      player: pc,
      orientation: pc,
      checkSquare:
          data["checkSq"] != null ? size.squareNumber(data["checkSq"]!) : null,
    );
    PlayState state = PlayState.ourTurn;
    print("Whose turn ? $state");
    gs = GameState(
      state: state,
      size: size,
      board: board,
      moves: moves,
      hands: game!.handSymbols(),
    );

    emit(gs!);
  }

// check if game is in checkmate
  bool isCheckmate() {
    if (game!.checkmate) {
      return true;
    }
    return false;
  }

// check if game is in draw
  bool isDraw() {
    if (game!.inDraw) {
      return true;
    }
    return false;
  }

// check if game is draw by threefold repition
  bool isThreeFoldRep() {
    if (vsEngine) {
      if (game!.repetition) {
        return true;
      }
      return false;
    } else {
      return checkRepetitionOnline();
    }
  }

// checking threefold repition in online mode
  bool checkRepetitionOnline() {
    for (var v in fenCounter.values) {
      if (v == 3) {
        return true;
      }
    }
    return false;
  }

// check if game is draw by insufficient material
  bool isInsuffMaterial() {
    if (game!.insufficientMaterial) {
      return true;
    }
    return false;
  }

// check if game is stalemate
  bool isStalemate() {
    if (game!.stalemate) {
      return true;
    }
    return false;
  }

// making engine move
  void engineMove(ChessBoard? widget) async {
    emitState(true);
    await Future.delayed(Duration(milliseconds: 250));
    bishop.EngineResult result = await compute(engineSearch, game!);
    if (result.hasMove) {
      print('Best Move: ${formatResult(result)}');
      game!.makeMove(result.move!);
      emitState();
      if (isCheckmate()) {
        widget!.showDialog(
            message: 'You Lose!',
            dialogueType: DialogType.ERROR,
            animType: AnimType.RIGHSLIDE,
            desc: '');
      } else if (isStalemate()) {
        widget!.showDialog(
            message: 'Stalemate!',
            dialogueType: DialogType.WARNING,
            animType: AnimType.BOTTOMSLIDE,
            desc: 'No valid moves possible');
      } else if (isDraw()) {
        widget!.showDialog(
            message: 'Draw!',
            dialogueType: DialogType.WARNING,
            animType: AnimType.TOPSLIDE,
            desc: '');
      }
    }
  }

// format the result of move made by engine
  String formatResult(bishop.EngineResult res) {
    if (game == null) return 'No Game';
    if (!res.hasMove) return 'No Move';
    String san = game!.toSan(res.move!);
    return '$san (${res.eval}) [depth ${res.depth}]';
  }
}

// maing the engine search for moves based on the given game state
Future<bishop.EngineResult> engineSearch(bishop.Game game) async {
  return await bishop.Engine(game: game)
      .search(timeLimit: 1000, timeBuffer: 500);
}

// GameState class for storing additional info about the game
class GameState extends Equatable {
  final PlayState state;
  final BoardSize size;
  final BoardState board;
  final List<Move> moves;
  final List<List<String>> hands;
  final bool thinking;

// make canMove true if its our turn
  bool get canMove => state == PlayState.ourTurn;

  GameState({
    required this.state,
    required this.size,
    required this.board,
    required this.moves,
    this.hands = const [[], []],
    this.thinking = false,
  });
  factory GameState.initial() => GameState(
      state: PlayState.idle,
      size: BoardSize.standard(),
      board: BoardState.empty(),
      moves: []);

  GameState copyWith({
    PlayState? state,
    BoardSize? size,
    BoardState? board,
    List<Move>? moves,
    List<List<String>>? hands,
    bool? thinking,
  }) {
    return GameState(
      state: state ?? this.state,
      size: size ?? this.size,
      board: board ?? this.board,
      moves: moves ?? this.moves,
      hands: hands ?? this.hands,
      thinking: thinking ?? this.thinking,
    );
  }

  List<Object> get props => [state, size, board, moves, hands, thinking];
  bool get stringify => true;
}

enum PlayState {
  idle,
  ourTurn,
  theirTurn,
  finished,
}

// convert from algebraic string to move
Move moveFromAlgebraic(String alg, BoardSize size) {
  if (alg[1] == '@') {
    int from = HAND;
    int to = size.squareNumber(alg.substring(2, 4));
    return Move(from: from, to: to, piece: alg[0].toUpperCase());
  }
  int from = size.squareNumber(alg.substring(0, 2));
  int to = size.squareNumber(alg.substring(2, 4));
  String? promo = (alg.length > 4) ? alg[4] : null;
  return Move(from: from, to: to, promo: promo);
}

// convert from move to algebraic string
String moveToAlgebraic(Move move, BoardSize size) {
  if (move.drop) {
    return '${move.piece!.toLowerCase()}@${size.squareName(move.to)}';
  } else {
    String from = size.squareName(move.from);
    String to = size.squareName(move.to);
    String alg = '$from$to';
    if (move.promotion) alg = '$alg${move.promo}';
    return alg;
  }
}
