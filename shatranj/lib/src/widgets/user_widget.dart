import 'package:flutter/material.dart';

class UserWidget extends StatelessWidget {
  final username;
  final profilePicURL;
  const UserWidget({Key? key, this.username, this.profilePicURL})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(profilePicURL),
          radius: 30,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          username.toUpperCase(),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
