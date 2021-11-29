import 'package:chess_ui/src/screens/chess_board_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  var userOnDeviceID;
  HomeScreen({Key? key, this.userOnDeviceID}) : super(key: key);

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
    return const Scaffold(
      body: Center(
        child: Text('HomeScreen'),
      ),
    );
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