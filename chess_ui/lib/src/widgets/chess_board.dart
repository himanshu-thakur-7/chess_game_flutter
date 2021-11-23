import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

var isPlayerOne = true;
const finalURL = "https://chess-server7.herokuapp.com";
const testURL = "http://localhost:8080";

class ChessBoardWidget extends StatefulWidget {
  const ChessBoardWidget({Key? key}) : super(key: key);

  @override
  _ChessBoardWidgetState createState() => _ChessBoardWidgetState();
}

ChessBoardController _controller = ChessBoardController();
IO.Socket socket = IO.io('/');

class _ChessBoardWidgetState extends State<ChessBoardWidget> {
  // final ChessBoardController _controller = ChessBoardController();
  void connectToServer() {
    print('connecting to server...');
    try {
      socket = IO.io(testURL, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });
      socket.connect();
      socket.on('connect', (_) {
        print('connected');
      });
      socket.emit('/test', 'test');
      socket.on(
          'startGame',
          (playerOneID) => {
                print('playerOneID: $playerOneID'),
                if (socket.id != playerOneID)
                  {
                    setState(() {
                      isPlayerOne = false;
                    })
                  }
              });

      socket.on('updateBoard', (data) {
        print('updateBoard');
        print(data);
        _controller.loadPGN(data);
        setState(() {});
      });

      socket.on("gameOver", (data) {
        print(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Checkmate'),
        ));
        socket.emit("Roger", {''});
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    _controller = ChessBoardController();

    connectToServer();

    print("init state");
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ChessBoard(
        boardOrientation: isPlayerOne ? PlayerColor.white : PlayerColor.black,
        boardColor: BoardColor.orange,
        controller: _controller,
        onMove: () {
          String currPGN = "";
          for (String? s in _controller.getSan()) {
            // print(s);
            currPGN += (s ?? "") + " ";
          }
          print(currPGN);

          socket.emit('moved', currPGN);

          if (_controller.isCheckMate()) {
            socket.emit("checkmate", {'checkmate ho gya hai bhai'});
          }

          // _controller.loadPGN(
          //     "1. e4 e5 2. Nc3 Nf6 3. f4 exf4 4. e5 d6 5. exf6 Qxf6 6. Qf3 Qxc3");
        }
        // if (_controller.isCheckMate()) {

        //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //     content: Text('Checkmate'),
        //   ));
        // }

        // Code to generate PGN after every move.. which will then be sent on server to be broadcasted to the other player

        // String currPGN = "";
        // for (String? s in _controller.getSan()) {
        //   print(s);
        //   currPGN += (s ?? "") + " ";
        // }
        // print(currPGN);
        ,
      ),
    );
  }
}
