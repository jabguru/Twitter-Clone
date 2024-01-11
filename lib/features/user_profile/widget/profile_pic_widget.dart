import 'package:flutter/material.dart';
import 'package:twitter_clone/theme/pallete.dart';

class ProfilePicWidget extends StatelessWidget {
  final String profilePic;
  final double radius;
  const ProfilePicWidget({
    super.key,
    required this.profilePic,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
      backgroundColor: Pallete.blueColor,
      radius: radius,
      child: profilePic.isEmpty
          ? const Icon(
              Icons.person,
              color: Pallete.whiteColor,
              size: 20,
            )
          : null,
    );
  }
}
