import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../custom_widget/simple_dialog.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(64.0),
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
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
              ),
            ),
            SizedBox(height: 20),

            _signUpBtn(context),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Switch to the Login screen
                Navigator.pop(context);
              },
              child: Text('Already have an account? Log in.'),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton _signUpBtn(BuildContext context) {
    return ElevatedButton(
            onPressed: () async {
              sayneLoadingDialog(context, "회원가입중");
              String email = _emailController.text.trim();
              String pw = _passwordController.text.trim();
              String cpw = _confirmPasswordController.text.trim();
              if(pw != cpw){
                simpleToast('confirm 비밀번호가 올바르지 않음');
                return;
              }
              try {
                UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: pw,
                );
                simpleToast('User ${userCredential.user?.uid} signed up success');
                if(mounted){
                  Navigator.pop(context);
                  Navigator.pop(context, {'email': email, 'password': pw});
                }
              }
              on FirebaseAuthException catch (e) {
                Navigator.pop(context);
                if (e.code == 'weak-password') {
                  simpleToast('The password provided is too weak.');
                } else if (e.code == 'email-already-in-use') {
                  simpleToast('The account already exists for that email.');
                }
              } catch (e) {
                print(e);
              }
              finally{
              }
            },
            child: Text('Sign up'),
          );
  }
}