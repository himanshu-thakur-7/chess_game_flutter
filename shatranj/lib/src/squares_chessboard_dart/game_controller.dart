import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bishop/bishop.dart' as bishop;
import 'package:bloc/bloc.dart';
// import 'package:chess_ui/src/board_decode.dart';
// import 'package:chess_ui/src/widgets/chess_board_test.dart';
// import 'package:chess_ui/src/widgets/chess_board_main.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:squares/squares.dart';
import 'package:bishop/src/move.dart' as M;

import 'square_chess_board.dart';

// TODO: Implement logic to communicate when the engine checkmates u
bishop.Game? game;
GameState? gs;
int? lf;
int? lt;
int? ck;
bool? playable;
GlobalKey<ChessBoard2State> gkc = GlobalKey();

// List<String>? board;

class GameController extends Cubit<GameState> {
  int pc = WHITE;
  GameController() : super(GameState.initial());
  bishop.Engine? engine;
  bool vsEngine = false;

  void printInfo() {
    // print(game!.turn);
  }

  checkSq() {
    return game!.info.checkSq;
  }

  // alterBoardOrientation(int orientation) {
  //   emit(GameState(
  //       state: state.board.copyWith(orientation: orientation),
  //       board:,
  //       size:,
  //       moves:,

  //       ));
  // }

  void emitState([bool thinking = false]) {
    // print("last move played was: ${game!.info.lastMove}");
    if (game == null) {
      // print("sorry bro .. game is nulllll :(");
      emit(GameState.initial());
    }
    BoardSize size = BoardSize(game!.size.h, game!.size.v);
    // bool canMove = game!.turn == WHITE || game!.turn == BLACK; // for pvp
    bool canMove = game!.turn == pc;
    if (!vsEngine) {
      canMove = false;
    }
    // bool canMove = game!.turn == WHITE; // for engine
    // set logic for can move in both cases vs player and vs engine

    // List<bishop.Move> _moves = canMove ? game!.generateLegalMoves() : [];
    List<M.Move> _moves = game!.generateLegalMoves();
    List<Move> moves = [];
    for (bishop.Move move in _moves) {
      String algebraic = game!.toAlgebraic(move);
      Move _move = moveFromAlgebraic(algebraic, size);
      moves.add(_move);
    }
    // print(moves);
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
    // bs = board;
    PlayState state = game!.gameOver
        ? PlayState.finished
        : (canMove ? PlayState.ourTurn : PlayState.theirTurn);

    // print(state);
    gs = GameState(
      state: state,
      thinking: thinking,
      size: size,
      board: board,
      moves: moves,
      hands: game!.handSymbols(),
    );
    // gkc.currentState!.setState(() {
    //   gkc.currentState!.canMove = true;
    // });
    emit(gs!);
    // print("Emitted successfully");
  }

  getGameState() {
    return gs;
  }

  getFen() {
    return game!.fen;
  }

  loadFen(fen) {
    // print("got from socket update event: $fen");
    String old = game!.fen;
    // print("before update:${game!.fen}");

    game!.loadFen(fen);

    String newFen = game!.fen;

    // print("After update:${game!.fen}");

    // print("Are they equal??? : ${old == newFen}");

    game = bishop.Game(variant: bishop.Variant.standard(), fen: fen);
    emitState();
  }

  isGameNull() {
    return game == null;
  }

  void startGame(
      {String? fen, required bool vsEngine, required int playerColor}) {
    pc = playerColor;
    // print("start game function game_controller.dart::::");

    game = bishop.Game(variant: bishop.Variant.standard(), fen: fen);
    // print("Line 73 -> startGame - game: ${game!.fen}");

    engine = bishop.Engine(game: game!);
    this.vsEngine = vsEngine;
    emitState();
  }

  void makeMove(Move move, {String? fen, bool? vsEngine, ChessBoard2? widget}) {
    // print(" Line 78 Move: $move");

    if (game == null) {
      // print("oops no game found yet... sorry!");
      return;
    }

    String alg = moveToAlgebraic(move, state.size);
    // print("Line 82 alg: $alg");
    bishop.Move? m = game!.getMove(alg);
    if (m == null)
      print('move $alg not found');
    else {
      game!.makeMove(m);
      // print("Line 88 moved success!");
      emitState();

      if (vsEngine!) {
        Future.delayed(Duration(milliseconds: 200))
            .then((_) => engineMove(widget));
        // engineMove();
      }
    }
  }

  void makeMovePlayer(data) {
    // print(data);
    game!.loadFen(data["fen"]);
    // print("Turn :${game!.turn}");
    BoardSize size = BoardSize(game!.size.h, game!.size.v);
    // bool canMove = game!.turn == WHITE || game!.turn == BLACK; // for pvp
    bool canMove = game!.turn != pc;
    print("Can i play ?:  $canMove");
    // bool canMove = game!.turn == WHITE; // for engine
    // set logic for can move in both cases vs player and vs engine

    // List<bishop.Move> _moves = canMove ? game!.generateLegalMoves() : [];
    // print(game!.makeMove(M.Move(
    //     from: boardDecode[data["lastFrom"]]!,
    //     to: boardDecode[data["lastTo"]]!)));
    List<M.Move> _legalmoves = game!.generateLegalMoves();
    // print(_legalmoves);
    List<Move> moves = [];
    for (bishop.Move move in _legalmoves) {
      String algebraic = game!.toAlgebraic(move);
      Move _move = moveFromAlgebraic(algebraic, size);
      moves.add(_move);
    }
    // print(moves);
    bishop.GameInfo gameInfo = game!.info;
    BoardState board = BoardState(
      board: game!.boardSymbols(),
      player: pc,
      orientation: pc,
      // lastFrom: boardDecode[data["lastFrom"]],
      // lastTo: boardDecode[data["lastTo"]],
      checkSquare:
          data["checkSq"] != null ? size.squareNumber(data["checkSq"]!) : null,
    );
    // bs = board;
    // PlayState state = game!.gameOver
    //     ? PlayState.finished
    //     : (canMove ? PlayState.ourTurn : PlayState.theirTurn);
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
    // String alg = moveToAlgebraic(move, state.size);
    // print("Line 82 alg: $alg");
    // Map<int?, int?> boardDecode = decodeBoard();
    // int? from = boardDecode[move.from];
    // int? to = boardDecode[move.to];

    // print("making move");
    // // print();
    // game!.makeMove(M.Move(from: move.from, to: move.to));
    // print(Move(from: move.from, to: move.to));
    // // game!.makeMove(m!);
    // print("move made ?");
    // emitState();
  }

  bool isCheckmate() {
    // if (game == null) {
    //   return true;
    // }
    if (game!.checkmate) {
      return true;
    }
    return false;
  }

  bool isDraw() {
    if (game!.inDraw) {
      return true;
    }
    return false;
  }

  bool isThreeFoldRep() {
    if (game!.repetition) {
      return true;
    }
    return false;
  }

  bool isInsuffMaterial() {
    if (game!.insufficientMaterial) {
      return true;
    }
    return false;
  }

  bool isStalemate() {
    if (game!.stalemate) {
      return true;
    }
    return false;
  }

  // void randomMove() {
  //   if (game == null || game!.gameOver) return;
  //   game!.makeRandomMove();
  //   emitState();
  // }

  void engineMove(ChessBoard2? widget) async {
    emitState(true);
    await Future.delayed(Duration(milliseconds: 250));
    // bishop.EngineResult result = await engine!.search();
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
      } else {
        widget!.showDialog(
            message: 'Draw!',
            dialogueType: DialogType.WARNING,
            animType: AnimType.TOPSLIDE,
            desc: '');
      }
    }
  }

  String formatResult(bishop.EngineResult res) {
    if (game == null) return 'No Game';
    if (!res.hasMove) return 'No Move';
    String san = game!.toSan(res.move!);
    return '$san (${res.eval}) [depth ${res.depth}]';
  }
}

Future<bishop.EngineResult> engineSearch(bishop.Game game) async {
  return await bishop.Engine(game: game)
      .search(timeLimit: 1000, timeBuffer: 500);
}

class GameState extends Equatable {
  final PlayState state;
  final BoardSize size;
  final BoardState board;
  final List<Move> moves;
  final List<List<String>> hands;
  final bool thinking;

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

Move moveFromAlgebraic(String alg, BoardSize size) {
  if (alg[1] == '@') {
    // it's a drop
    int from = HAND;
    int to = size.squareNumber(alg.substring(2, 4));
    return Move(from: from, to: to, piece: alg[0].toUpperCase());
  }
  int from = size.squareNumber(alg.substring(0, 2));
  int to = size.squareNumber(alg.substring(2, 4));
  String? promo = (alg.length > 4) ? alg[4] : null;
  return Move(from: from, to: to, promo: promo);
}

String moveToAlgebraic(Move move, BoardSize size) {
  // print('${move.piece!.toLowerCase()}@${size.squareName(move.to)}');
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
