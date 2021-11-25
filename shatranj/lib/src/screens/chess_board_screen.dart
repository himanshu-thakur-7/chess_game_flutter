import 'package:flutter/material.dart';
import '../widgets/chess_board.dart';

class ChessBoardScreen extends StatelessWidget {
  final String? roomID;
  const ChessBoardScreen({Key? key, this.roomID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess App'),
      ),
      body: ChessBoardWidget(
        roomID: roomID,
      ),
    );
  }
}
