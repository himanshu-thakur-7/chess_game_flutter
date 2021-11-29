import 'package:chess_ui/src/screens/chess_board_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  var userOnDeviceID;
  // var profilePic;
  HomeScreen({
    Key? key,
    this.userOnDeviceID,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                // margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                            child: Container(
                                margin: const EdgeInsets.only(right: 120),
                                child: const CircleAvatar())),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 120),
                            child: IconButton(
                              icon: const Icon(
                                Icons.more_vert_outlined,
                                color: Colors.green,
                              ),
                              onPressed: () => {print('hi')},
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
                                          fontSize: 30),
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
                                            const Color.fromRGBO(
                                                155, 26, 228, 1.0),
                                          ),
                                        ),
                                        onPressed: () => {print('puzzles')},
                                        child: const Text(
                                          'Puzzles',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  )
                                ]),
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
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            155, 26, 228, 1.0),
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Play Vs Robot',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                35, 16, 2, 2),
                                            child: Image.asset(
                                              "graphics/play_ai.png",
                                              fit: BoxFit.contain,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.28,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            0, 210, 211, 1.0),
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Play Vs Friend',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                35, 16, 2, 2),
                                            child: Image.asset(
                                              "graphics/play_friend.png",
                                              fit: BoxFit.contain,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.28,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
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
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            0, 210, 211, 1.0),
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Learn To Play',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  35, 16, 2, 2),
                                              child: SvgPicture.asset(
                                                'graphics/learnChess.svg',
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.28,
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            155, 26, 228, 1.0),
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      child: const Center(
                                          child: Text(
                                        'PLAY',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900),
                                      )),
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
        ));
  }
}
//   return Scaffold(
//   body: Padding(
//     padding: const EdgeInsets.all(8.0),
//     child: TextField(
//       controller: _controller,
//       autofocus: true,
//       decoration: const InputDecoration(
//         hintText: 'Enter Room ID',
//       ),
//     ),
//   ),
//   floatingActionButton: FloatingActionButton(
//     onPressed: () {
//       print('pressed');
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ChessBoardScreen(
//             userOnDeviceID: widget.userOnDeviceID,
//             roomID: _controller.text,
//           ),
//         ),
//       );
//     },
//     child: const Icon(Icons.arrow_forward),
//   ),
// );
