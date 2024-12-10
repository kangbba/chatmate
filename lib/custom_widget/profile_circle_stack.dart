import 'package:flutter/material.dart';
import '../custom_widget/profile_circle.dart';

import '../classes/user_model.dart';

class ProfileCircleStack extends StatelessWidget {
  final List<UserModel> users;
  final double maxRectangleSize;

  const ProfileCircleStack({
    required this.users,
    required this.maxRectangleSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: maxRectangleSize,
      height: maxRectangleSize,
      child: Stack(
        children: [
          for (int i = 0; i < users.length.clamp(0, 4); i++)
            Positioned(
              left: getProfileCircleLocation(users.length, i)[0],
              right: getProfileCircleLocation(users.length, i)[1],
              top: getProfileCircleLocation(users.length, i)[2],
              bottom: getProfileCircleLocation(users.length, i)[3],
              child: ProfileCircle(
                userModel: users[i],
                radius: getProperRadius(users.length),
              ),
            ),
        ],
      ),
    );
  }
  List<double?> getProfileCircleLocation(int clampedUsersCount, int userIndex){
    switch(clampedUsersCount) {
      case 0:
        return <double?> [0, 0, 0, 0];
      case 1:
        return <double?> [0, 0, 0, 0];
      case 2:
        if(userIndex == 0){
          return <double?> [0.0, null, 0.0, null];
        }
        else{
          return <double?> [null, 0, null, 0.0];
        }
      case 3:
        if(userIndex == 0){
          return <double?> [10, 10, 0.0, null];
        }
        else if(userIndex == 1){
          return <double?> [0.0, null, null, 0];
        }
        else{
          return <double?> [null, 0, null, 0];
        }
      default:
        if(userIndex == 0){
          return <double?> [0.0, null, 0.0, null];
        }
        else if(userIndex == 1){
          return <double?> [null, 0, 0, null];
        }
        else if(userIndex == 2){
          return <double?> [0.0, null, null, 0];
        }
        else{
          return <double?> [null, 0, null, 0];
        }
    }

  }

  double getProperRadius(int usersCount){
    switch(usersCount){
      case 0 :
        return 0;
      case 1 :
        return 26;
      case 2 :
        return 14.5;
      case 3 :
        return 13.5;
      default :
        return 15;
    }
  }
}
