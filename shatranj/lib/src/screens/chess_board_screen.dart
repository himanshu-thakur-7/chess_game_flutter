import 'package:flutter/material.dart';
import '../widgets/chess_board_main.dart';

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
    print("chess screen initiated");
    super.initState();
    print("vsengine: ${widget.comp}");
  }

  @override
  void dispose() {
    print("chess screen disposed");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
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
              context: context,
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
