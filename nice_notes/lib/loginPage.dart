import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nice_notes/main.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'authFunctions.dart';
import 'signupPage.dart';
import 'todolist.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  void goToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  void goToTasks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ToDoListPage(),
      ),
    );
  }

  void _showButtonPressDialog(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider Button Pressed!'),
        backgroundColor: Colors.black26,
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 50, 100),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 90, 170, 250),
        centerTitle: true,
        title: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHomePage(
                    title: 'Nice Tasks',
                  ),
                ),
              );
            },
            child: const Text(
              'Nice Tasks',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 30),
            )),
        actions: [
          IconButton(
              onPressed: () async {
                await GoogleSignIn().signOut(); // Google Sign Out
                FirebaseAuth.instance.signOut(); // Email/PW Sign Out
                ScaffoldMessenger.of(
                        context) // snackbar notification to let the user know they're signed out
                    .showSnackBar(const SnackBar(content: Text('Logged Out')));
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            // Welcome Description
            Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(7.5)),
                  color: Color.fromARGB(255, 90, 170, 250)),
              width: MediaQuery.of(context).size.width / 2,
              child: const Text(
                'Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(7.5)),
                  color: Color.fromARGB(255, 90, 170, 250)),
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Form(
                    key: _formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          key: const ValueKey('email'),
                          decoration:
                              const InputDecoration(hintText: 'Enter Email'),
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'Please Enter A Valid Email';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            email = value!;
                          },
                        ),
                        TextFormField(
                          key: const ValueKey('password'),
                          obscureText: true,
                          decoration:
                              const InputDecoration(hintText: 'Enter Password'),
                          validator: (value) {
                            if (value!.length < 6) {
                              return "Password Must Be > Than 6 Characters";
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            password = value!;
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 5, 50, 100),
                                minimumSize: Size(400, 40)),
                            onPressed: () {
                              if (_formkey.currentState!.validate()) {
                                _formkey.currentState!.save();
                              }
                              AuthServices.signinUser(email, password, context);
                            },
                            child: const Text('Submit')),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Column(children: [
              Container(
                  child: SignInButton(
                Buttons.googleDark,
                onPressed: () async => {
                  await AuthServices().signInGoogle(
                      context), //added an await here so that the redirect doesn't happen b4 the user is signed in
                  goToTasks(context)
                },
              )),
            ]),
            Column(
              children: [
                RichText(
                    text: TextSpan(
                        text:
                            "Don't Have An Account?\nTap Here To Go To The Signup Page",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => goToSignup(context)))
              ],
            )
          ])),
    );
  }
}
