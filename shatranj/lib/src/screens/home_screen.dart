import 'package:chess_ui/src/screens/auth_screen.dart';
import 'package:chess_ui/src/screens/chess_board_screen.dart';
import 'package:chess_ui/src/screens/learn_chess_screen.dart';
import 'package:chess_ui/src/screens/stats_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../widgets/dashboard_widget.dart';

class HomeScreen extends StatefulWidget {
  var userOnDeviceID;
  HomeScreen({
    Key? key,
    this.userOnDeviceID,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var profilePicURL;
  var userName;

  var roomID;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final snapshots = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userOnDeviceID)
        .snapshots();
    print(snapshots.forEach((element) {
      print(element.get("image_url"));

      setState(() {
        profilePicURL = element.get("image_url");
        userName = element.get("username");
      });
    }));
  }

  final TextEditingController _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Container(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 19,
                                backgroundImage: NetworkImage(profilePicURL ??
                                    "https://cdn.iconscout.com/icon/free/png-256/face-1659511-1410033.png"),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    "Hi ${userName ?? ""}!",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          margin: const EdgeInsets.only(left: 120),
                          child: IconButton(
                            icon: const Icon(
                              Icons.exit_to_app_outlined,
                              color: Colors.green,
                            ),
                            onPressed: () => {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.QUESTION,
                                headerAnimationLoop: true,
                                animType: AnimType.BOTTOMSLIDE,
                                title: 'LOG OUT',
                                desc: 'Do you wish to log out ?',
                                btnOkText: "Yes",
                                btnCancelText: "No",
                                dismissOnTouchOutside: false,
                                buttonsTextStyle:
                                    const TextStyle(color: Colors.white),
                                showCloseIcon: true,
                                btnCancelOnPress: () {},
                                btnOkOnPress: () async {
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AuthScreen()));
                                },
                              ).show()
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: const Color.fromRGBO(251, 209, 76, 1.0),
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(18)),
                      child: Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  ' Let\'s Become\n a New\n Chessmaster ',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                ),
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        const Color.fromRGBO(155, 26, 228, 1.0),
                                      ),
                                    ),
                                    onPressed: () => {
                                          print("puzzle screen"),
                                        },
                                    child: const Text(
                                      "Let's go",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    )),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                DashboardWidget(
                                  imgScale: 0.24,
                                  flexVal: 1,
                                  widget: widget,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ChessBoardScreen(
                                          comp: true,
                                          roomID: null,
                                          userOnDeviceID: widget.userOnDeviceID,
                                        ),
                                      ),
                                    );
                                  },
                                  backColor:
                                      const Color.fromRGBO(155, 26, 228, 1.0),
                                  imgURL: "graphics/play_ai.png",
                                  title: "Play vs Robot",
                                ),
                                DashboardWidget(
                                    imgScale: 0.24,
                                    flexVal: 1,
                                    widget: widget,
                                    onTap: () {
                                      AwesomeDialog(
                                        dismissOnTouchOutside: false,
                                        context: context,
                                        dialogType: DialogType.INFO_REVERSED,
                                        borderSide: const BorderSide(
                                            color: Colors.green, width: 2),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        buttonsBorderRadius:
                                            const BorderRadius.all(
                                                Radius.circular(2)),
                                        headerAnimationLoop: false,
                                        animType: AnimType.BOTTOMSLIDE,
                                        body: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextField(
                                                controller: _controller,
                                                keyboardType:
                                                    TextInputType.name,
                                                decoration:
                                                    const InputDecoration(
                                                  focusColor: Color.fromRGBO(
                                                      34, 0, 53, 1.0),
                                                  labelText: 'Enter Room ID',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        showCloseIcon: true,
                                        btnCancelOnPress: () {},
                                        btnOkText: 'Join',
                                        btnOkOnPress: () {
                                          var rid = _controller.text;
                                          print("room ID : ${rid}");

                                          Navigator.of(context)
                                              .push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChessBoardScreen(
                                                comp: false,
                                                roomID: rid,
                                                userOnDeviceID:
                                                    widget.userOnDeviceID,
                                              ),
                                            ),
                                          )
                                              .then((value) {
                                            if (value != null) {
                                              print(value);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      backgroundColor:
                                                          Colors.amber[700],
                                                      content: Text(value)));
                                            }
                                          });
                                          _controller.clear();
                                        },
                                      ).show();
                                    },
                                    backColor:
                                        const Color.fromRGBO(0, 210, 211, 1.0),
                                    imgURL: "graphics/play_friend.png",
                                    title: "Play vs Friend")
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const StatsScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            251, 209, 76, 1.0),
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            child: Image.asset(
                                              "graphics/stats.png",
                                              fit: BoxFit.contain,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.12,
                                            ),
                                          ),
                                          const Text(
                                            'Stats',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                DashboardWidget(
                                  widget: widget,
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const LearnChessScreen()));
                                  },
                                  backColor:
                                      const Color.fromRGBO(0, 210, 211, 1.0),
                                  imgURL: "graphics/learnChess.svg",
                                  title: "Chess Lessons",
                                  flexVal: 2,
                                  imgScale: 0.24,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          155, 26, 228, 1.0),
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    child: Center(
                                        child:
                                            Image.asset('graphics/icon.png')),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              child: Image.asset(
                'graphics/main_pic.png',
                width: MediaQuery.of(context).size.width * 2,
              ),
              left: 24,
              right: -150,
              top: 130,
            )
          ],
        ),
      ),
    );
  }
}
