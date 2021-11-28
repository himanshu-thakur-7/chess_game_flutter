import 'dart:async';

import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  bool isColorWhite = true;
  TimerWidget({Key? key, required this.isColorWhite}) : super(key: key);

  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  Duration _duration = const Duration(minutes: 1);
  Timer? timer;
  @override
  void initState() {
    super.initState();
    // startTimer();
  }

  void addTime() {
    const updateSeconds = -1;
    setState(() {
      final seconds = _duration.inSeconds + updateSeconds;
      _duration = Duration(seconds: seconds);
      if (seconds <= 0) {
        timer?.cancel();
      }
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void stopTimer({bool resets = true}) {
    setState(() {
      timer?.cancel();
    });
  }

  void resumeTimer() {
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_duration.inMinutes.remainder(60));
    final seconds = twoDigits(_duration.inSeconds.remainder(60));
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isColorWhite ? Colors.white70 : Colors.black87,
            border: Border.all(
              width: 1,
            ),
          ),
          child: Text(
            '$minutes : $seconds',
            style: TextStyle(
              color: widget.isColorWhite ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}
//   Widget buildTimeCard({required String time}) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Text(
//           time,
//           style: const TextStyle(
//             fontSize: 40,
//             // color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }

