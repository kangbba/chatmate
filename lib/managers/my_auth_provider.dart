import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../classes/user_model.dart';

enum LoginPlatform{
  standard,
  google,
  facebook,
  apple,
}

class MyAuthProvider with ChangeNotifier{
  static MyAuthProvider? _instance;
  static MyAuthProvider get instance {
    _instance ??= MyAuthProvider();
    return _instance!;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInAnonymously() async{
    return await _auth.signInAnonymously();
  }

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  Future<UserCredential> signInStandard(String email, String pw) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: pw,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message,
      );
    } catch (e) {
      throw FirebaseAuthException(
        code: 'ERROR_LOGIN_FAILED',
        message: '로그인에 실패했습니다. 다시 시도해주세요.',
      );
    } finally {
      // finally 블록에서 필요한 코드를 실행해 줍니다.
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Google 로그인이 취소되었습니다.',
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      throw FirebaseAuthException(
        code: 'ERROR_SIGN_IN_FAILED',
        message: 'Google 로그인에 실패했습니다. 다시 시도해주세요.',
        // Firebase Authentication 예외를 던지기 때문에 stack trace도 포함시켜줍니다.
      );
    }
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await googleSignIn.signOut();
      return true;
    } catch (error) {
      print("구글 로그아웃 도중 에러발생 : $error");
      throw FirebaseAuthException(
        code: 'ERROR_SIGN_OUT_FAILED',
        message: 'Google 로그아웃에 실패했습니다. 다시 시도해주세요.',
        // Firebase Authentication 예외를 던지기 때문에 stack trace도 포함시켜줍니다.
      );
    }
  }



  User? get curUser{
    return FirebaseAuth.instance.currentUser;
  }
  UserModel? get curUserModel{
    if(curUser == null){
        return null;
    }
    return UserModel.fromFirebaseUser(curUser!);
  }

  Future<User?> getUserFromEmail(String email) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: "dummyPassword", // 일시적으로 필요한 필드입니다.
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
    return null;
  }

}