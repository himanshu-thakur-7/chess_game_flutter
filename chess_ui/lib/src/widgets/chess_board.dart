import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

bool isPlayerOne = true;
bool isPlayerTurn = true;
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
                      isPlayerTurn = false;
                    })
                  }
              });

      socket.on('updateBoard', (data) {
        print('updateBoard');
        print(data);
        _controller.loadPGN(data);
        setState(() {
          isPlayerTurn = true;
        });
      });

      socket.on("Checkmate", (data) {
        print(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Checkmate'),
        ));
        socket.emit("Roger", {'Checkmate'});
      });

      socket.on("Stalemate", (data) {
        print(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Stalemate'),
        ));
        socket.emit("Roger", {'Stalemate'});
      });

      socket.on("Draw", (data) {
        print(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Draw'),
        ));
        setState(() {
          isPlayerTurn = false;
        });
        socket.emit("Roger", {'Draw'});
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
        enableUserMoves: isPlayerTurn,
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
          } else if (_controller.isStaleMate()) {
            socket.emit("stalemate", {'stalemate ho gya hai bhai'});
          } else if (_controller.isDraw() ||
              _controller.isInsufficientMaterial() ||
              _controller.isThreefoldRepetition()) {
            socket.emit("draw", {'draw ho gya hai bhai'});
          }

          setState(() {
            isPlayerTurn = false;
          });
        },
      ),
    );
  }
}
