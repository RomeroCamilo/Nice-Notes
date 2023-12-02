import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'loginPage.dart';
import 'signupPage.dart';
import 'firebase_options.dart';
import 'todolist.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Nice Tasks',
      home: MyHomePage(
        title: 'Nice Tasks',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 50, 100),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 90, 170, 250),
        title: Center(
            child: Text(
          widget.title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 30),
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
                'WELCOME',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 200,
                  child: FittedBox(
                    child: FloatingActionButton.extended(
                        heroTag: 'To Do List Page Button',
                        backgroundColor:
                            const Color.fromARGB(255, 90, 170, 250),
                        label: const Text('YOUR TASKS'),
                        onPressed: () async {
                          if (FirebaseAuth.instance.currentUser != null) {
                            goToTasks(context);
                          }
                        }),
                  ),
                ),
              ],
            ),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 125,
                  child: FittedBox(
                    child: FloatingActionButton.extended(
                        heroTag: 'Sign Up Button',
                        backgroundColor:
                            const Color.fromARGB(255, 90, 170, 250),
                        label: const Text('SIGN UP'),
                        onPressed: () async {
                          goToSignup(context);
                        }),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: FittedBox(
                    child: FloatingActionButton.extended(
                      heroTag: 'Log In Button',
                      backgroundColor: const Color.fromARGB(255, 90, 170, 250),
                      label: const Text('LOGIN'),
                      onPressed: () async {
                        goToLogin(context);
                      },
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
