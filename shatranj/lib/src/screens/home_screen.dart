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
  final String? userOnDeviceID;
  const HomeScreen({
    Key? key,
    required this.userOnDeviceID,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? profilePicURL;
  String? userName;

  var roomID;
  @override
  void initState() {
    super.initState();

    //  Get the current user information (username and profile picture )
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // this is set so as to avoid overflow of contents on screen in situation like keyboard overlay
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        // this ensures that all the content on the screen is inside area visible to the user
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context)
                  .size
                  .height, // setting the dimensions of container wrt dimensions of the screen
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10),
              child: Column(
                // Main Wrapper Column in UI
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .end, // aligning all children inside Row to the right / end of the row
                    children: [
                      Expanded(
                        flex:
                            7, // this child of row will take 7/12th of total space available in row (since for other child flex = 5.. hence total = 7+5 = 12)
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 19,
                              backgroundImage: NetworkImage(
                                  profilePicURL ?? //if somehow the profilePic url could not be loaded.. load from this back up url
                                      "https://cdn.iconscout.com/icon/free/png-256/face-1659511-1410033.png"),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  "Hi ${userName ?? ""}!", // interpolating the user name to greet
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
                              // event handle on pressing the icon

                              // user will be displayed a dialog box asking whether or not to log out
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
                                  await FirebaseAuth.instance
                                      .signOut(); // signing out the user
                                  Navigator.pushReplacement(
                                      context, // redirecting the user to the AuthScreen
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
                    // 2nd Child of Main UI Wrapper
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
                                          print(""),
                                          // Future Prospect of adding a Chess puzzle  feature
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
                    //3rd Child of the main UI wrapper
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
                                  // Play vs Robot Card
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
                                    // Play vs Friend Card
                                    imgScale: 0.24,
                                    flexVal: 1,
                                    widget: widget,
                                    onTap: () {
                                      // Prompt the user to enter some user ID to join or start a new game online

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
                                          Radius.circular(2),
                                        ),
                                        headerAnimationLoop: false,
                                        animType: AnimType.BOTTOMSLIDE,
                                        body: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextField(
                                                // text field to input room id
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
                                        btnCancelOnPress: () {},
                                        btnOkText: 'Join',
                                        btnOkOnPress: () {
                                          // get the room id entered by the user and redirect him to chessboard screen along with his credentials
                                          var rid = _controller.text;
                                          print("room ID : $rid");

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
                                            //  when the user comes back to thus screen ... and some value has been sent back from the other screen
                                            if (value != null) {
                                              print(value);
                                              // show the message to the user in form of snack bar
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      backgroundColor:
                                                          Colors.amber[700],
                                                      content: Text(value)));
                                            }
                                          });
                                          // clear the residual value from controller if any
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
                                  // show stats card
                                  flex: 1,
                                  child: InkWell(
                                    // widget to detect tap (like a gesture detector)
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
                                  // Chess Lessons Card
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
              // Putting the image of titans at last to position it at the top of the stack
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
