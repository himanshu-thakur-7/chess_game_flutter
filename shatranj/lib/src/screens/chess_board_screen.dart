import 'package:flutter/material.dart';
import '../widgets/chess_board.dart';

class ChessBoardScreen extends StatelessWidget {
  var userOnDeviceID;
  final String? roomID;
  final bool comp;
  ChessBoardScreen(
      {Key? key, this.roomID, this.userOnDeviceID, required this.comp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 210, 211, 1.0),
        title: const Text('Chess App'),
      ),
      body: ChessBoardWidget(
        comp: comp,
        roomID: roomID,
        userOnDeviceID: userOnDeviceID,
      ),
    );
  }
}
