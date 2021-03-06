import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squares/squares.dart';
import 'game_controller.dart';

class ChessBoard extends StatefulWidget {
  final GameController gc = GameController();
  final int boardOrientation;
  final Function onMove;
  final Function showDialog;
  final bool? vsComp;
  final GlobalKey chessKey;
  bool canMove;
  final userOnDeviceID;

  ChessBoard({
    Key? key,
    required GameController? gc,
    required this.boardOrientation,
    required this.onMove,
    required this.showDialog,
    required this.canMove,
    this.vsComp,
    this.userOnDeviceID,
    required this.chessKey,
  }) : super(key: key);

  @override
  ChessBoardState createState() => ChessBoardState();
}

class ChessBoardState extends State<ChessBoard> {
  PieceSet pieceSet = PieceSet.merida();

  @override
  void initState() {
    super.initState();
    startGame();
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant ChessBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gc.getFen() != "") {
      print("loading updated fen");
      startGame(fen: widget.gc.getFen());
    } else {
      startGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        key: widget.chessKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocBuilder<GameController, GameState>(
                bloc: widget.gc,
                builder: (context, state) {
                  return BoardController(
                    state: state.board
                        .copyWith(orientation: widget.boardOrientation),
                    pieceSet: pieceSet,
                    // setting board theme
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
                    canMove: widget.vsComp! == true ? true : widget.canMove,
                    draggable: false,
                  );
                },
              ),
            ),
          ],
        ));
  }

// function program to start game
  void startGame({String? fen}) {
    widget.gc.startGame(
        fen: fen, vsEngine: false, playerColor: widget.boardOrientation);
  }

// on move handler
  void onMove(Move move) {
    widget.gc.makeMove(move, vsEngine: widget.vsComp, widget: widget);

    if (widget.vsComp! == false) {
      widget.onMove(move.from, move.to);
    } else {
      widget.canMove = false;
      setState(() {});
    }
    if (widget.gc.isCheckmate()) {
      if (widget.vsComp! == false) {
        FirebaseFirestore.instance
            .collection("users")
            .doc("${widget.userOnDeviceID}")
            .update({
          "wins": FieldValue.increment(1),
          "total": FieldValue.increment(1),
        }).then(
          (_) => {
            print("stats updated!"),
          },
        );
      }

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
      if (widget.vsComp! == true) {
        widget.showDialog(
            message: 'Stalemate!',
            dialogueType: DialogType.WARNING,
            animType: AnimType.BOTTOMSLIDE,
            desc: 'No valid moves possible');
      }
    }
    if (widget.gc.isDraw() ||
        widget.gc.isInsuffMaterial() ||
        widget.gc.isThreeFoldRep()) {
      if (widget.vsComp! == true) {
        widget.showDialog(
            message: 'Draw!',
            dialogueType: DialogType.WARNING,
            animType: AnimType.TOPSLIDE,
            desc: '');
      }
    }
  }

// convert from algebraic to move
  Move moveFromAlgebraic(String alg, BoardSize size) {
    int from = size.squareNumber(alg.substring(0, 2));
    int to = size.squareNumber(alg.substring(2, 4));
    return Move(from: from, to: to);
  }
}
