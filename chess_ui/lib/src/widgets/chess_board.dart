import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
      socket = IO.io('http://localhost:8080', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });
      socket.connect();
      socket.on('connect', (_) {
        print('connected');
      });
      socket.emit('/test', 'test');
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
