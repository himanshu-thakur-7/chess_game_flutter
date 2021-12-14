import 'package:flutter/material.dart';
import '../widgets/chess_board_main.dart';
import '../squares_chessboard_dart/square_chess_board.dart';

class ChessBoardScreen extends StatefulWidget {
  var userOnDeviceID;
  final String? roomID;
  final bool comp;
  ChessBoardScreen(
      {Key? key, this.roomID, this.userOnDeviceID, required this.comp})
      : super(key: key);

  @override
  State<ChessBoardScreen> createState() => _ChessBoardScreenState();
}

class _ChessBoardScreenState extends State<ChessBoardScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("vsengine: ${widget.comp}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      // appBar: AppBar(
      //   backgroundColor: const Color.fromRGBO(0, 210, 211, 1.0),
      //   title: const Text('Let\'s Play'),
      // ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Image.asset(
                'graphics/horse.png',
                width: MediaQuery.of(context).size.width * 0.22,
                height: MediaQuery.of(context).size.height * 0.14,
              ),
            ),
            ChessBoardWidget(
              comp: this.widget.comp,
              roomID: widget.roomID,
              userOnDeviceID: widget.userOnDeviceID,
            ),
          ],
        ),
      ),
      // body: const ChessBoardWidget(),
    );
  }
}
