import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:chess_ui/src/squares_chessboard_dart/square_chess_board.dart';
import 'package:chess_ui/src/squares_chessboard_dart/game_controller.dart';
import 'package:chess_ui/src/widgets/user_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:squares/squares.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

GlobalKey<ChessBoard2State> ck = GlobalKey<ChessBoard2State>();

bool? isPlayerWhite;
bool? isPlayerTurn;
String? existingSocketId;

const finalURL = "https://chess-server7.herokuapp.com";
const testURL = "http://localhost:8080";

class ChessBoardWidget extends StatefulWidget {
  String? roomID;
  final BuildContext context;
  final userOnDeviceID;
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
          var userDocument = snapshot.data;
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
          existingSocketId = socket.id;

          if (mounted) {
            t = Timer(
                Duration(seconds: 30),
                () => {
                      Navigator.of(widget.context)
                          .pop('Sorry! No opponent joined'),
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
            );
            dialog.show();
          }
          if (widget.roomID != null) {
            print("Socket ${socket.id} connected");
            print(widget.roomID);
            socket.emit('playerReady', widget.roomID);
          }
          socket.on("Error", (msg) => print(msg));
          socket.on("Roger", (msg) => print(msg));
        });

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
                      if (mounted)
                        setState(() {
                          isPlayerWhite = false;
                          isPlayerTurn = false;
                        }),
                      // emit()
                    }
                });

        socket.on(
            'roomFull',
            (rid) => {
                  print("Room ID FULL: $rid"),
                  if (mounted)
                    {
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
                        btnOkText: 'Main Menu',
                        dismissOnTouchOutside: false,
                      ).show(),
                    }
                  else
                    {
                      print("not mounted"),
                    }
                });
        socket.on('updateBoard', (data) {
          print('updateBoard');

          _controller.makeMovePlayer(data);
          if (mounted) {
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
    _controller = GameController();
    isPlayerTurn = true;
    isPlayerWhite = true;
    existingSocketId = "";
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
  }

  void communicateMoves(int from, int to) {
    List<int> moveInfo = [from, to];
    print(_controller.getGameState());
    socket.emit('moved', {
      "lastFrom": from,
      "lastTo": to,
      "checkSq": _controller.checkSq(),
      "fen": _controller.getFen()
    });

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
    return Container(
      height: MediaQuery.of(context).size.height / 1.2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          opponentID == null
              ? const UserWidget(
                  username: "computer",
                  profilePicURL:
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQXHCK1BEpJ_YSw8Po8kAG6gRu2OVnTGH6YXg&usqp=CAU")
              : buildUserWidget(opponentID),
          const SizedBox(height: 10),
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
          buildUserWidget(widget.userOnDeviceID),
        ],
      ),
    );
    // : const RoomFullScreen();
  }
}
