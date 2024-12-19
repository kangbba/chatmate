import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../managers/my_auth_provider.dart';
import '../custom_widget/simple_dialog.dart';
import '../screens/changing_nickname_screen.dart';
import '../modes/ServerConversation/server_room_screen.dart';
import '../screens/main_screen.dart';
import '../screens/signup_screen.dart';

import '../helper/local_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authProvider = MyAuthProvider.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadRememberMe();
    _authProvider.googleSignIn.signInSilently();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.black38,),
                    ),
                  ),
                ),
                FutureBuilder<bool>(
                  future: LocalStorage.getRememberMeLocal(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CheckboxListTile(
                        title: Text("Remember Me"),
                        value: snapshot.data!,
                        onChanged: (value) async {
                          await LocalStorage.setRememberMeLocal(value!);
                          setState(() {

                          });
                        },
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
                SizedBox(height: 20),
                _standardLogInBtn(),
                SizedBox(height: 30),
                _anonymousLogInBtn(),
                _googleLogInBtn(),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Switch to the Signup screen
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()))
                        .then((data) async {
                      if (data != null) {
                        String email = data['email'];
                        String password = data['password'];
                        _emailController.text = email;
                        _passwordController.text = password;
                        _obscurePassword = true;
                        bool rememberMe = await LocalStorage.getRememberMeLocal();
                        await onPressedSignInStandard(email, password, rememberMe);
                      }
                    });
                  },
                  child: Text('Need an account? Sign up.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
// 로그인 버튼을 눌렀을 때 호출되는 함수

// 앱을 실행할 때 호출되는 함수
  void loadRememberMe() async {
    bool rememberMe = await LocalStorage.getRememberMeLocal(); // 값을 불러옵니다.
    String recentId = rememberMe ? await LocalStorage.getRecentIdLocal() : '';
    setState(() {
      _emailController.text = recentId;
    });
  }
  Widget _googleLogInBtn() {
    return TextButton(
      onPressed: () async {
        sayneLoadingDialog(context, "로그인중");
        try {
          UserCredential userCredential = await _authProvider.signInWithGoogle();
          // 로그인이 성공한 경우, UserCredential 객체를 사용하여 로그인한 사용자의 정보를 가져옵니다.
          User user = userCredential.user!;
          simpleToast("${user.email}");
          if(mounted){
            Navigator.pop(context);
            if(_authProvider.curUser?.displayName?.isNotEmpty ?? false){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
            }
            else{
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangingNicknameScreen()),
              ).then((value) {
                // 이전 화면으로 되돌아올 때 실행될 코드 작성
                MaterialPageRoute(builder: (context) => MainScreen());
              });
            }
          }
        } on FirebaseAuthException catch (e) {
          Navigator.pop(context);
          if (e.code == 'ERROR_ABORTED_BY_USER') {
            simpleToast("ERROR_ABORTED_BY_USER");
            // 사용자가 Google 로그인을 취소한 경우 처리할 코드
          } else if (e.code == 'ERROR_SIGN_IN_FAILED') {
            simpleToast("ERROR_SIGN_IN_FAILED");
            debugPrint("ERROR_SIGN_IN_FAILED ${e.message}");
            // Google 로그인에 실패한 경우 처리할 코드
          }
        } catch (e) {
          // FirebaseAuthException이 아닌 다른 예외가 발생한 경우 처리할 코드
        }
      },
      child: Text('Login with Google'),
    );
  }

  Widget _standardLogInBtn() {
    return ElevatedButton(
            onPressed: () async {
              String email = _emailController.text.trim();
              String password = _passwordController.text.trim();
              bool rememberMe = await LocalStorage.getRememberMeLocal();
              await onPressedSignInStandard(email, password, rememberMe);
            },
            child: Text('Login'),
          );
  }

  Future<void> onPressedSignInStandard(String email, String password, bool rememberMe) async {
    sayneLoadingDialog(context, "로그인중");
    try {
      UserCredential userCredential = await _authProvider.signInStandard(email, password);
      // 로그인 성공 시 처리할 코드를 작성합니다.
      if(rememberMe){
        LocalStorage.setRecentIdLocal(email);
        print("유저가 최근 아이디를 기억해달라고 요청하였음");
      }
      if(mounted){
        Navigator.pop(context);
         if(_authProvider.curUser?.displayName?.isNotEmpty ?? false){
           Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => MainScreen()),
           );
         }
         else{
           // 현재화면에서 ChangingNicknameScreen 호출
           Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => ChangingNicknameScreen()),
           ).then((value) {
             // 이전 화면으로 되돌아올 때 실행될 코드 작성
             MaterialPageRoute(builder: (context) => MainScreen());
           });
         }
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      // Firebase Authentication 예외 처리
      if (e.code == 'user-not-found') {
        simpleToast('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        simpleToast('Wrong password provided for that user.');
      } else {
        simpleToast('Firebase Authentication 예외: ${e.message}');
      }
    } catch (e) {
      // 그 외 예외 처리
      simpleToast('예외 발생: $e');
    }
  }
  Widget _anonymousLogInBtn() {
    return TextButton(
      onPressed: () async {
        sayneLoadingDialog(context, "로그인중");
        try {
          UserCredential userCredential = await _authProvider.signInAnonymously();
          // 로그인이 성공한 경우, UserCredential 객체를 사용하여 로그인한 사용자의 정보를 가져옵니다.
          User user = userCredential.user!;
          simpleToast("Anonymous user logged in with UID: ${user.uid}");
          if (mounted) {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          }
        } on FirebaseAuthException catch (e) {
          Navigator.pop(context);
          simpleToast("Firebase Auth Exception: ${e.message}");
        } catch (e) {
          debugPrint('예외 발생: $e');
        }
      },
      child: Text('Login Anonymously'),
    );
  }

}
