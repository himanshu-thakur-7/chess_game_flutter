import 'package:flutter/material.dart';
import '../widgets/chess_board.dart';

class ChessBoardScreen extends StatelessWidget {
  var userOnDeviceID;
  final String? roomID;
  ChessBoardScreen({Key? key, this.roomID, this.userOnDeviceID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess App'),
      ),
      body: ChessBoardWidget(
        roomID: roomID,
        userOnDeviceID: userOnDeviceID,
      ),
    );
  }
}
