import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:http/http.dart' as http;

const API = "https://api.chess.com/pub/puzzle/random";

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({Key? key}) : super(key: key);

  @override
  _PuzzleScreenState createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  late ChessBoardController _controller;

  getPuzzle() async {
    while (true) {
      var response = await http.get(Uri.parse(API));

      var data = json.decode(response.body);
      var fen = data["fen"];
      var pgn = data["pgn"];
      List<String> pgn_array = pgn.split("\n");
      print(pgn_array.length);
      if (pgn_array.length != 6) {
        continue;
      } else
        print(pgn_array[pgn_array.length - 2]);
      _controller.loadFen(fen);
      setState(() {});
      break;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = ChessBoardController();

    //  make api call
    getPuzzle();
    // print(_controller.getSan());
    // setState(() {
    //   _controller.loadFen("8/8/4pK2/Rr1k3p/1P6/8/8/8 b - - 0 1");
    // });
  }

  // r\n1. Qxe5 fxe5 2. Bxe5+ Rg7 3. Bxg7+ Kxg7 4. Rxc8\r\n

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        title: Text("Daily Puzzle"),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
                onPressed: () => {getPuzzle()},
                child: const Text(
                  "NextPuzzle",
                  style: TextStyle(color: Colors.white),
                )),
            Container(
              child: ChessBoard(
                onMove: () => print(_controller.game),
                boardColor: BoardColor.darkBrown,
                controller: _controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
