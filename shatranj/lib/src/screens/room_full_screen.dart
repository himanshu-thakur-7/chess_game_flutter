import 'package:flutter/material.dart';

class RoomFullScreen extends StatelessWidget {
  const RoomFullScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(
            Icons.error,
            size: 100,
            color: Colors.red,
          ),
          Text(
            'Sorry, The room ID you entered is currently occupied.. please try some other ID',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
