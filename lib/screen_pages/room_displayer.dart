import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/my_auth_provider.dart';

import '../classes/chat_room.dart';
import '../classes/user_model.dart';
import '../custom_widget/profile_circle.dart';

class RoomDisplayer extends StatefulWidget {
  const RoomDisplayer({required this.chatRoom, super.key});

  final ChatRoom chatRoom;

  @override
  State<RoomDisplayer> createState() => _RoomDisplayerState();
}

class _RoomDisplayerState extends State<RoomDisplayer> {
  final MyAuthProvider _authProvider = MyAuthProvider.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    if(_authProvider.curUser == null){
      return const Text("Login is required");
    }
    return MultiProvider(
      providers: [
        StreamProvider<List<UserModel>>(
          create: (_) => widget.chatRoom.userModelsStream,
          initialData: const [],
        ),
      ],
      child: Consumer<List<UserModel>>(
        builder: (_, userModelSnapshot, __) {
// 예외 처리
          if (userModelSnapshot.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          List<UserModel> userModels = userModelSnapshot;
          final curUserModel = UserModel.fromFirebaseUser( _authProvider.curUser!);
          final curUserUid = curUserModel.uid;
          final hostUserUid = widget.chatRoom.host.uid;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: userModels.length,
            itemBuilder: (context, index) {
              final UserModel userModel = userModels[index];
              return _memberListTile(context, userModel, curUserUid, hostUserUid);
            },
          );
        },
      ),
    );
  }

  ListTile _memberListTile(BuildContext context, UserModel userModel, String curUserUid, String hostUserUid) {
    final uid = userModel.uid;
    final displayName = userModel.displayName;
    final isMe = userModel.uid == curUserUid;
    final isCurUser = userModel.uid == curUserUid;
    final isCurUserHost = curUserUid == hostUserUid;
    final isHost = userModel.uid == hostUserUid;
    final email = userModel.email;
    final isUndefined = email.isEmpty;
    final photoURL = userModel.photoURL;
    return ListTile(
              onTap: (){
                if(!isCurUser) {
                  showContextMenu(context, userModel, isCurUserHost && !isCurUser);
                }
              },
              leading: ProfileCircle(userModel: userModel, radius: 20,),
              title:  Text((isUndefined ? uid : displayName) + (isMe ? " (나)" : ""), style: TextStyle(fontSize: isUndefined ? 12 : 16),),
              subtitle: Text(isUndefined ? '익명' : email),
              trailing: isHost ? const Text("호스트") : null,
            );
  }
  void showContextMenu(BuildContext context, UserModel user, bool useManagementFunction) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final List<PopupMenuEntry<String>> menuItems = [
      if (useManagementFunction)
        const PopupMenuItem(
          value: 'setHost',
          child: Text('발표자 위임'),
        ),

      const PopupMenuItem<String>(
        value: 'whisper',
        child: Text('귓속말'),
      ),
    ];

    // Show the context menu and wait for a selection.
    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        const Rect.fromLTWH(0, 0, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: menuItems,
    ).then((String? value) {
      // Handle the selected menu item.
      if (value == 'setHost') {
        onTapListTile(context, user);
      }
    });
  }
  void onTapListTile(BuildContext context, UserModel user) async {
     widget.chatRoom.setHost(user);
     setState(() {

     });
  }



}
