import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
// import 'package:bishop/bishop.dart' as bishop;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squares/squares.dart';
import 'game_controller.dart';

class ChessBoard2 extends StatefulWidget {
  final GameController gc = GameController();
  final int boardOrientation;
  final Function onMove;
  final Function showDialog;
  final bool? vsComp;
  final GlobalKey chessKey;
  bool canMove;
  ChessBoard2({
    Key? key,
    required GameController? gc,
    required this.boardOrientation,
    required this.onMove,
    required this.showDialog,
    required this.canMove,
    this.vsComp,
    required this.chessKey,
  }) : super(key: key);

  @override
  ChessBoard2State createState() => ChessBoard2State();
}

class ChessBoard2State extends State<ChessBoard2> {
  PieceSet pieceSet = PieceSet.merida();
  // bool? canMove;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startGame();
    setState(() {});
  }

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
    // print("canMove");
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
                  return BoardController(
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
                    canMove: widget.vsComp! == true ? true : widget.canMove,
                    // canMove: true,
                    draggable: false,
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
    widget.gc.makeMove(move, vsEngine: widget.vsComp, widget: widget);

    if (widget.vsComp! == false) {
      widget.onMove(move.from, move.to);
    } else {
      widget.canMove = false;
      setState(() {});
    }
    if (widget.gc.isCheckmate()) {
      setState(() {
        widget.canMove = false;
      });
      widget.showDialog(
          message: 'You Win!!',
          animType: AnimType.LEFTSLIDE,
          dialogueType: DialogType.SUCCES,
          desc: '');
    }
    if (widget.gc.isStalemate()) {
      setState(() {
        widget.canMove = false;
      });
      widget.showDialog(
          message: 'Stalemate!',
          dialogueType: DialogType.WARNING,
          animType: AnimType.BOTTOMSLIDE,
          desc: 'No valid moves possible');
    }
    if (widget.gc.isDraw()) {
      setState(() {
        widget.canMove = false;
      });
      widget.showDialog(
          message: 'Draw!',
          dialogueType: DialogType.WARNING,
          animType: AnimType.TOPSLIDE,
          desc: '');
    }
  }

  Move moveFromAlgebraic(String alg, BoardSize size) {
    int from = size.squareNumber(alg.substring(0, 2));
    int to = size.squareNumber(alg.substring(2, 4));
    return Move(from: from, to: to);
  }
}
