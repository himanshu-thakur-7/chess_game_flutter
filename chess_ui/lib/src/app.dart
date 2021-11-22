import 'package:flutter/material.dart';
import './widgets/chess_board.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Chess App'),
        ),
        body: const ChessBoardWidget(),
      ),
    );
  }
}
