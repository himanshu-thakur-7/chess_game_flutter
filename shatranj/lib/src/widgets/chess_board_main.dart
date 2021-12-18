import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:chess_ui/src/screens/home_screen.dart';
import 'package:chess_ui/src/squares_chessboard_dart/square_chess_board.dart';
import 'package:chess_ui/src/squares_chessboard_dart/game_controller.dart';
import 'package:chess_ui/src/widgets/user_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc;
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:squares/squares.dart';
// import "package:bloc/bloc.dart";
import '../widgets/timer_widget.dart';
import 'package:squares/src/move.dart' as Move;

import '../screens/room_full_screen.dart';

import 'package:flutter/material.dart';
// import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../board_decode.dart';

Map<int?, int?> boardDecode = decodeBoard();
// import "../engine/logic.dart";
GlobalKey<ChessBoard2State> ck = GlobalKey<ChessBoard2State>();

GlobalKey<TimerWidgetState> _myKey = GlobalKey();
GlobalKey<TimerWidgetState> _opponentKey = GlobalKey();

bool? isPlayerWhite;
bool? isPlayerTurn;

const finalURL = "https://chess-server7.herokuapp.com";
const testURL = "http://localhost:8080";
// var opponentID = null;

class ChessBoardWidget extends StatefulWidget {
  String? roomID;
  final BuildContext context;
  var userOnDeviceID;
  final bool comp;
  ChessBoardWidget({
    Key? key,
    this.roomID,
    this.userOnDeviceID,
    required this.context,
    required this.comp,
  }) : super(key: key);

  @override
  _ChessBoardWidgetState createState() => _ChessBoardWidgetState();
}

GameController _controller = GameController();
IO.Socket socket = IO.io('/');

int? lock;

class _ChessBoardWidgetState extends State<ChessBoardWidget> {
  bool canJoin = true;
  var opponentID;
  // final ChessBoardController _controller = ChessBoardController();
  var t = Timer(Duration(seconds: 1000000000000), () {});
  var dialog;
  Widget buildUserWidget(String userID) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Text("Loading...");
          }
          // print(snapshot);
          var userDocument = snapshot.data;
          // print(userDocument!.get("username"));
          final username = userDocument!.get("username");
          final profilePicURL = userDocument.get("image_url");
          return UserWidget(username: username, profilePicURL: profilePicURL);
        });
  }

  void connectToServer() {
    print('connecting to server...');

    if (widget.roomID != null) {
      try {
        // establishing connection and opening the sockets

        socket.on('connect', (_) {
          //  if (lock == 0) {
//           print("Param: $_");
//           print("connection success");
          if (mounted) {
            t = Timer(
                Duration(seconds: 30),
                () => {
                      print("yo bro"),
                      // socket.emit('game abandoned', "opponent did'nt join"),
                      // socket.emit('exit room'),
                      Navigator.of(widget.context)
                          .pop('Sorry! No opponent joined'),
                      // socket.disconnect(),
                      print("srry bro"),
                      t.cancel(),
                    });
            lock = 0;

            dialog = AwesomeDialog(
              context: context,
              animType: AnimType.SCALE,
              dialogType: DialogType.INFO,
              title: 'Room Joined.',
              desc: 'Waiting for other player...',
              headerAnimationLoop: false,
              autoHide: const Duration(seconds: 28),
              useRootNavigator: true,
              dismissOnTouchOutside: false,
              dismissOnBackKeyPress: false,
              // btnOkOnPress: () {},
            );
            dialog.show();
          }
//           lock = 1;
//            }
          if (widget.roomID != null) {
            print("Socket ${socket.id} connected");
            print(widget.roomID);
            socket.emit('playerReady', widget.roomID);
          }
          socket.on("Error", (msg) => print(msg));
          socket.on("Roger", (msg) => print(msg));
        });
        // set the players as white or black on game start
        socket.on(
            'startGame',
            (playerOneID) => {
                  if (mounted)
                    {
                      t.cancel(),
                      dialog.dismiss(),
                      setState(() {}),
                    },
                  _controller.emitState(),
                  print("${_controller.isGameNull()}: from start game event"),
                  socket.emit('loadUser', widget.userOnDeviceID),
                  socket.on(
                      'displayUser',
                      (userID) => {
                            if (mounted)
                              setState(() {
                                // get opponent userID stored in firebase
                                opponentID = userID;
                              })
                          }),
                  print('playerOneID: $playerOneID'),
                  if (socket.id != playerOneID)
                    {
                      // _myKey.currentState?.stopTimer(),
                      // _opponentKey.currentState?.startTimer(),
                      if (mounted)
                        setState(() {
                          isPlayerWhite = false;
                          isPlayerTurn = false;
                        }),
                      // emit()
                    }
                  else
                    {
                      // _myKey.currentState?.startTimer(),
                      // _opponentKey.currentState?.stopTimer()
                    }
                });

        socket.on(
            'roomFull',
            (rid) => {
                  print("Room ID FULL: $rid"),
                  if (mounted)
                    {
                      // setState(() {
                      //   canJoin = false;
                      // })
                      AwesomeDialog(
                        context: widget.context,
                        animType: AnimType.SCALE,
                        headerAnimationLoop: true,
                        dialogType: DialogType.ERROR,
                        showCloseIcon: false,
                        title: "Room is full",
                        desc: 'Sorry.. Room is occupied. Please try later.',
                        onDissmissCallback: (type) => {
                          print("callback called"),
                          Navigator.of(context).pop()
                        },
                        // btnOkIcon: Icons.check_circle,
                        btnOkOnPress: () {
                          // Navigator.of(context).pop();
                        },
                        btnOkText: 'Main Menu',
                        dismissOnTouchOutside: false,
                      ).show(),
                    }
                  else
                    {
                      print("not mounted"),
                    }
                });
// update the state of the board when the server notifies the client of a move
        socket.on('updateBoard', (data) {
          // print("${_controller.isGameNull()} : from update board event!");
          // stop the timer of the player who made the move and start the timer of the other player
          // _opponentKey.currentState?.stopTimer();
          // _myKey.currentState?.startTimer();

          print('updateBoard');
          // print(
          // "here is the game state from line 134 socket update event: $data");
          // int? from = boardDecode[data[0]];
          // int? to = boardDecode[data[1]];
          _controller.makeMovePlayer(data);
          if (mounted) {
            // setState(() {});
            // _controller.loadFen(data);

            // _controller.loadPGN(data);

            setState(() {
              isPlayerTurn = true;
            });
          }
        });
        // checkmate event handler
        socket.on("Checkmate", (data) {
          print("checkmate event");
          print(data);

//  update stats in data base

          informUser(
              message: 'You Lose!',
              dialogueType: DialogType.ERROR,
              animType: AnimType.RIGHSLIDE,
              desc: '');

          // AwesomeDialog(
          //   width: MediaQuery.of(context).size.width,
          //   context: context,
          //   dialogType: DialogType.ERROR,
          //   animType: AnimType.RIGHSLIDE,
          //   headerAnimationLoop: true,
          //   title: 'You Lose!!',
          //   desc: '',
          //   btnOkOnPress: () {},
          //   btnOkIcon: Icons.cancel,
          //   btnOkColor: Colors.red,
          //   dismissOnTouchOutside: false,
          // ).show();
          FirebaseFirestore.instance
              .collection("users")
              .doc("${widget.userOnDeviceID}")
              .update({
            "losses": FieldValue.increment(1),
            "total": FieldValue.increment(1),
          }).then(
            (_) => {
              print("stats updated!"),
            },
          );
          socket.emit("Roger", {'Checkmate'});
        });
        // // stalemate event handler
        socket.on("Stalemate", (data) {
          informUser(
              message: 'Stalemate!',
              dialogueType: DialogType.WARNING,
              animType: AnimType.BOTTOMSLIDE,
              desc: 'No valid moves possible');
          // AwesomeDialog(
          //         context: context,
          //         dialogType: DialogType.INFO,
          //         headerAnimationLoop: true,
          //         animType: AnimType.BOTTOMSLIDE,
          //         showCloseIcon: false,
          //         title: 'Stalemate!',
          //         desc: 'Either Player unable to make valid move.',
          //         btnCancelOnPress: () {},
          //         btnOkOnPress: () {})
          //     .show();
          // socket.emit("Roger", {'Stalemate'});
          FirebaseFirestore.instance
              .collection("users")
              .doc("${widget.userOnDeviceID}")
              .update({
            "draws": FieldValue.increment(1),
            "total": FieldValue.increment(1),
          }).then(
            (_) => {
              print("stats updated!"),
            },
          );
        });
        // // draw event handler
        socket.on("Draw", (data) {
          informUser(
              message: 'Draw!',
              dialogueType: DialogType.WARNING,
              animType: AnimType.TOPSLIDE,
              desc: data);
          // AwesomeDialog(
          //         context: context,
          //         dialogType: DialogType.WARNING,
          //         headerAnimationLoop: true,
          //         animType: AnimType.TOPSLIDE,
          //         showCloseIcon: false,
          //         title: 'Draw!',
          //         desc: data,
          //         btnCancelOnPress: () {},
          //         btnOkOnPress: () {})
          //     .show();
          FirebaseFirestore.instance
              .collection("users")
              .doc("${widget.userOnDeviceID}")
              .update({
            "draws": FieldValue.increment(1),
            "total": FieldValue.increment(1),
          }).then(
            (_) => {
              print("stats updated!"),
            },
          );
          socket.emit("Roger", {'Draw'});
        });
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (mounted) {
      super.dispose();
      print("Chess widget disposed");
      socket.emit('exit room');
      socket.disconnect();
      widget.roomID = null;
    }
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    // _controller = GameController();
    _controller = GameController();
    isPlayerTurn = true;
    isPlayerWhite = true;
    // socket = IO.io('/');

    lock = 0;
    if (widget.comp == false) {
      socket = IO.io(finalURL, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });
      if (mounted) {
        socket.connect();

        connectToServer();
      } else {
        print("aur bhai.. hum to connected h!!!");
      }
    }
    // print("init state");
  }

  // getMoveFromEngine() async {
  //   String move = await getEngineMove(_controller.getFen());

  //   setState(() {
  //     _controller.makeMoveWithNormalNotation(move);

  //     isPlayerTurn = true;
  //   });
  // }

  void communicateMoves(int from, int to) {
    // print("$move printed from parent screen");

    // List<String> moveComp = move.toString().split('-');
    // print(moveComp[0]);
    // print(moveComp[1]);
    List<int> moveInfo = [from, to];
    print(_controller.getGameState());
    socket.emit('moved', {
      "lastFrom": from,
      "lastTo": to,
      "checkSq": _controller.checkSq(),
      "fen": _controller.getFen()
    });
    // socket.emit('moved', _controller.getFen());

    // check if the player is in checkmate
    if (_controller.isCheckmate()) {
      socket.emit("checkmate", {'checkmate ho gya hai bhai'});
    }
    // // check stalemate
    else if (_controller.isStalemate()) {
      socket.emit("stalemate", {'stalemate ho gya hai bhai'});
    }
    // // check draw
    else if (_controller.isDraw() ||
        _controller.isInsuffMaterial() ||
        _controller.isThreeFoldRep()) {
      print("draw");
      var reason = "";

      if (_controller.isInsuffMaterial()) {
        reason = "Insufficient Material";
      } else if (_controller.isThreeFoldRep()) {
        reason = "By Threefold Repition";
      }

      socket.emit("draw", reason);
    } else {
      print("threefold rep: ${_controller.isThreeFoldRep()}");
    }
    setState(() {
      isPlayerTurn = false;
    });

    // print("from the parent screen");
  }

  informUser({
    message,
    dialogueType,
    animType,
    desc,
  }) {
    if (mounted) {
      AwesomeDialog(
        context: widget.context,
        animType: animType,
        headerAnimationLoop: true,
        dialogType: dialogueType,
        showCloseIcon: false,
        title: message,
        desc: desc,

        // btnOkIcon: Icons.check_circle,
        btnOkOnPress: () {
          Navigator.of(widget.context).pop();
        },
        btnOkText: 'Main Menu',
        dismissOnTouchOutside: false,
      ).show();
    }
    if (!mounted) {
      print("error not mounted ");
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("setState called HotReload: PArent Screen");
    return Container(
      height: MediaQuery.of(context).size.height / 1.2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // TimerWidget(
          //   key: _opponentKey,
          //   isColorWhite: !isPlayerWhite,
          // ),
          opponentID == null
              ? const UserWidget(
                  username: "computer",
                  profilePicURL:
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQXHCK1BEpJ_YSw8Po8kAG6gRu2OVnTGH6YXg&usqp=CAU")
              : buildUserWidget(opponentID),
          const SizedBox(height: 10),
          // ChessBoard(
          //   size: MediaQuery.of(context).size.height * 0.5,
          //   enableUserMoves: isPlayerTurn,
          //   boardOrientation:
          //       isPlayerWhite ? PlayerColor.white : PlayerColor.black,
          //   boardColor: BoardColor.darkBrown,
          //   controller: _controller,
          //   onMove: () {
          //     // stop the timer of the player who made the move and start the timer of the other player
          //     // _myKey.currentState?.stopTimer();
          //     // _opponentKey.currentState?.startTimer();

          //     if (!widget.comp) {
          //       String currPGN = "";
          //       for (String? s in _controller.getSan()) {
          //         currPGN += (s ?? "") + " ";
          //       }
          //       print(currPGN);

          //       socket.emit('moved', currPGN);

          //       // check if the player is in checkmate
          //       if (_controller.isCheckMate()) {
          //         socket
          //             .emit("checkmate", {'checkmate ho gya hai bhai'});
          //       }
          //       // check stalemate
          //       else if (_controller.isStaleMate()) {
          //         socket
          //             .emit("stalemate", {'stalemate ho gya hai bhai'});
          //       }
          //       // check draw
          //       else if (_controller.isDraw() ||
          //           _controller.isInsufficientMaterial() ||
          //           _controller.isThreefoldRepetition()) {
          //         socket.emit("draw", {'draw ho gya hai bhai'});
          //       }

          //       // if the player has made a move, then it is not their turn anymore
          //       setState(() {
          //         isPlayerTurn = false;
          //       });
          //     } else {
          //       setState(() {
          //         isPlayerTurn = false;
          //       });
          //       getMoveFromEngine();
          //       // getEngineMove(_controller.getFen());
          //       // TODO: Set up engine move functionality

          //     }
          //   },
          // ),
          ChessBoard2(
            userOnDeviceID: widget.userOnDeviceID,
            showDialog: informUser,
            chessKey: ck,
            boardOrientation: isPlayerWhite! ? WHITE : BLACK,
            gc: _controller,
            canMove: isPlayerTurn!,
            onMove: communicateMoves,
            vsComp: widget.comp,
          ),
          const SizedBox(height: 10),
          // TimerWidget(
          //   key: _myKey,
          //   isColorWhite: isPlayerWhite,
          // ),
          buildUserWidget(widget.userOnDeviceID),
        ],
      ),
    );
    // : const RoomFullScreen();
  }
}
