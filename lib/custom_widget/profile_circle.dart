
import 'dart:math';
import 'package:flutter/material.dart';
import '../classes/user_model.dart';

class ProfileCircle extends StatefulWidget {
  const ProfileCircle({
    super.key,
    required this.userModel,
    required this.radius,
  });

  final UserModel userModel;
  final double radius;

  @override
  State<ProfileCircle> createState() => _ProfileCircleState();
}
class _ProfileCircleState extends State<ProfileCircle> { // 사용 가능한 아이콘 리스트
  late IconData randomIcon;
  final List<IconData> iconOptions = [
    Icons.person,
  ];
  @override
  void initState() {
    super.initState();
    randomIcon = _getRandomIcon();
  }
  IconData _getRandomIcon() {
    final random = Random();
    return iconOptions[random.nextInt(iconOptions.length)]; // 아이콘 리스트 중 무작위 선택
  }
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius * 0.68),
      child: widget.userModel.photoURL.isEmpty
          ? Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        color: Colors.grey[300], // 배경 색상 설정
        child: Icon(
          randomIcon, // 기본 아이콘
          size: widget.radius, // 아이콘 크기를 radius와 비슷하게 설정
          color: Colors.grey[600],
        ),
      )
          : Image(
        width: widget.radius * 2,
        height: widget.radius * 2,
        fit: BoxFit.cover,
        image: NetworkImage(widget.userModel.photoURL),
      ),
    );
  }

}
