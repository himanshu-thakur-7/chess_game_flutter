import 'package:flutter/material.dart';
// import 'package:bishop/bishop.dart' as bishop;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squares/squares.dart';
import 'game_controller.dart';

class ChessBoard2 extends StatefulWidget {
  final GameController gc = GameController();
  final int boardOrientation;
  final Function onMove;
  final bool? vsComp;
  final GlobalKey chessKey;
  ChessBoard2({
    Key? key,
    required GameController? gc,
    required this.boardOrientation,
    required this.onMove,
    // this.canMove,
    this.vsComp,
    required this.chessKey,
  }) : super(key: key);

  @override
  ChessBoard2State createState() => ChessBoard2State();
}

class ChessBoard2State extends State<ChessBoard2> {
  PieceSet pieceSet = PieceSet.merida();
  bool? canMove;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startGame();
  }

  // @override
  // // void didChangeDependencies() {
  // //   print("hi");
  // //   // TODO: implement didChangeDependencies
  // //   super.didChangeDependencies();
  // //   startGame();
  // // }

  @override
  void didUpdateWidget(covariant ChessBoard2 oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.gc.getFen() != "") {
      print("loading updated fen");
      startGame(fen: widget.gc.getFen());
    } else {
      print("calling start game from didUpdateWidget ");
      startGame();
      print("hi from did update dep");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("setState called HotReload: Child Screen");
    return Center(
        key: widget.chessKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // if (variant.hands) _hand(gc, BLACK),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: BlocBuilder<GameController, GameState>(
                bloc: widget.gc,
                builder: (context, state) {
                  // print("builder called");
                  // print(state.moves);
                  return Transform(
                    transform: Matrix4.rotationY(0),
                    child: BoardController(
                      state: state.board
                          .copyWith(orientation: widget.boardOrientation),
                      pieceSet: pieceSet,
                      theme: widget.boardOrientation == WHITE
                          ? const BoardTheme(
                              lightSquare: Color(0xffdee3e6),
                              darkSquare: Color(0xff788a94),
                              check: Color(0xffcb3927),
                              checkmate: Colors.orange,
                              previous: Color(0x809bc700),
                              selected: Color(0x8014551e),
                              premove: Color(0x807b56b3),
                            )
                          : const BoardTheme(
                              lightSquare: Color(0xff788a94),
                              darkSquare: Color(0xffdee3e6),
                              check: Color(0xffcb3927),
                              checkmate: Colors.orange,
                              previous: Color(0x809bc700),
                              selected: Color(0x8014551e),
                              premove: Color(0x807b56b3),
                            ),
                      size: state.size,
                      onMove: onMove,
                      moves: state.moves,
                      // canMove: widget.vsComp! ? state.canMove : widget.canMove!,
                      canMove: canMove ?? false,
                      draggable: false,
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }

  void startGame({String? fen}) {
    widget.gc.startGame(
        fen: fen, vsEngine: false, playerColor: widget.boardOrientation);
  }

  void onMove(Move move) {
    // print("hi");
    widget.gc.printInfo();

    // print("vsEngine: ${widget.vsComp}");
    widget.gc.makeMove(move, vsEngine: widget.vsComp);

    if (widget.vsComp! == false)
      widget.onMove(move.from, move.to);
    else {
      canMove = false;
      setState(() {});
    }
    // widget.gc.isCheckmate() ? print("checkmate!") : print("game on");
  }

  Move moveFromAlgebraic(String alg, BoardSize size) {
    int from = size.squareNumber(alg.substring(0, 2));
    int to = size.squareNumber(alg.substring(2, 4));
    return Move(from: from, to: to);
  }
}
