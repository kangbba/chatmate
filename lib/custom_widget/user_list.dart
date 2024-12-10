import '../custom_widget/profile_circle.dart';
import '../managers/my_auth_provider.dart';
import 'package:flutter/material.dart';
import '../classes/user_model.dart';

class UserList extends StatefulWidget {
  final Stream<List<UserModel>> userModelsStream;
  const UserList({Key? key, required this.userModelsStream}) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final MyAuthProvider myAuthProvider = MyAuthProvider.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: const [
              Icon(Icons.people, color: Colors.black45),
              SizedBox(width: 8),
              Text("참여자 목록", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<UserModel>>(
          stream: widget.userModelsStream,
          initialData: [],
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            final userModels = snapshot.data ?? [];
            return ListView.builder(
              shrinkWrap: true, // 내용이 적을 때는 스크롤 없이 표시
              itemCount: userModels.length,
              itemBuilder: (context, index) {
                final user = userModels[index];
                bool isUnknown = user.email.isEmpty;
                bool isMe = myAuthProvider.curUserModel?.uid == user.uid;
                return ListTile(
                  leading: ProfileCircle(userModel: user, radius: 20),
                  title: Text('${user.email.isEmpty ? "Unknown ${index + 1}" : user.displayName}  ${isMe ? '(Me)' : ''}'),
                  subtitle: Text('${isUnknown ? user.uid : user.email}', style: TextStyle(fontSize: 12)),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
