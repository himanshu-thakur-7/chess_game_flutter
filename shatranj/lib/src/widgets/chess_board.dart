import '../widgets/timer_widget.dart';

import '../screens/room_full_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

GlobalKey<TimerWidgetState> _myKey = GlobalKey();
GlobalKey<TimerWidgetState> _opponentKey = GlobalKey();

bool isPlayerWhite = true;
bool isPlayerTurn = true;
bool canJoin = true;
const finalURL = "https://chess-server7.herokuapp.com";
const testURL = "http://localhost:8080";

class ChessBoardWidget extends StatefulWidget {
  final String? roomID;
  const ChessBoardWidget({Key? key, this.roomID}) : super(key: key);

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
      // establishing connection and opening the sockets
      socket = IO.io(finalURL, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });
      socket.connect();
      socket.on('connect', (_) {
        print("Socket ${socket.id} connected");
        socket.emit('playerReady', widget.roomID);
      });
      // set the players as white or black on game start
      socket.on(
          'startGame',
          (playerOneID) => {
                print('playerOneID: $playerOneID'),
                if (socket.id != playerOneID)
                  {
                    // _myKey.currentState?.stopTimer(),
                    // _opponentKey.currentState?.startTimer(),
                    setState(() {
                      isPlayerWhite = false;
                      isPlayerTurn = false;
                    }),
                  }
                else
                  {
                    // _myKey.currentState?.startTimer(),
                    // _opponentKey.currentState?.stopTimer()
                  }
              });

      socket.on(
          'roomFull',
          (_) => {
                print('room full'),
                setState(() {
                  canJoin = false;
                })
              });
// update the state of the board when the server notifies the client of a move
      socket.on('updateBoard', (data) {
        // stop the timer of the player who made the move and start the timer of the other player
        // _opponentKey.currentState?.stopTimer();
        // _myKey.currentState?.startTimer();

        print('updateBoard');
        print(data);
        _controller.loadPGN(data);

        setState(() {
          isPlayerTurn = true;
        });
      });
      // checkmate event handler
      socket.on("Checkmate", (data) {
        print(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Checkmate'),
        ));
        socket.emit("Roger", {'Checkmate'});
      });
      // stalemate event handler
      socket.on("Stalemate", (data) {
        print(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Stalemate'),
        ));
        socket.emit("Roger", {'Stalemate'});
      });
      // draw event handler
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
    return canJoin
        ? Center(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // TimerWidget(
                  //   key: _opponentKey,
                  //   isColorWhite: !isPlayerWhite,
                  // ),
                  const SizedBox(height: 10),
                  ChessBoard(
                    size: MediaQuery.of(context).size.height * 0.5,
                    enableUserMoves: isPlayerTurn,
                    boardOrientation:
                        isPlayerWhite ? PlayerColor.white : PlayerColor.black,
                    boardColor: BoardColor.orange,
                    controller: _controller,
                    onMove: () {
                      // stop the timer of the player who made the move and start the timer of the other player
                      // _myKey.currentState?.stopTimer();
                      // _opponentKey.currentState?.startTimer();

                      String currPGN = "";
                      for (String? s in _controller.getSan()) {
                        currPGN += (s ?? "") + " ";
                      }
                      print(currPGN);

                      socket.emit('moved', currPGN);

                      // check if the player is in checkmate
                      if (_controller.isCheckMate()) {
                        socket.emit("checkmate", {'checkmate ho gya hai bhai'});
                      }
                      // check stalemate
                      else if (_controller.isStaleMate()) {
                        socket.emit("stalemate", {'stalemate ho gya hai bhai'});
                      }
                      // check draw
                      else if (_controller.isDraw() ||
                          _controller.isInsufficientMaterial() ||
                          _controller.isThreefoldRepetition()) {
                        socket.emit("draw", {'draw ho gya hai bhai'});
                      }

                      // if the player has made a move, then it is not their turn anymore
                      setState(() {
                        isPlayerTurn = false;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  // TimerWidget(
                  //   key: _myKey,
                  //   isColorWhite: isPlayerWhite,
                  // )
                ],
              ),
            ),
          )
        : const RoomFullScreen();
  }
}
