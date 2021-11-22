import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

class ChessBoardWidget extends StatefulWidget {
  const ChessBoardWidget({Key? key}) : super(key: key);

  @override
  _ChessBoardWidgetState createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget> {
  final ChessBoardController _controller = ChessBoardController();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ChessBoard(
        boardColor: BoardColor.orange,
        controller: _controller,
        onMove: () {
          // if (_controller.isCheckMate()) {

          //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          //     content: Text('Checkmate'),
          //   ));
          // }

          print(_controller.getSan());
        },
      ),
    );
  }
}
