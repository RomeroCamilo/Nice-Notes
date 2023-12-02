import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nice_notes/loginPage.dart';
import 'package:nice_notes/todolist.dart';

// Website below is about the functions to access firebase authentication
// https://firebase.google.com/docs/auth/flutter/manage-users
void goToLogin(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginPage()),
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

class AuthServices {
  signInGoogle(context) async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    if (gUser == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error')));
    }
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Access the uid of the newly created user
    String uid = userCredential.user!.uid;

    // Access the uid of the newly created user
    String username = userCredential.user!.email!;

    // Step 3: Trigger Cloud Function to create user in the cloud
    await addUserCloud(uid, username);

    // finding a way to retrieve and connect the uid/email to mySQL
    // print(FirebaseAuth.instance.currentUser!.uid); <----- WORKS IN MAIN.DART/ETC.DART AS WELL AS HERE
    // WITH SAME FUNCTIONALITY, MIGHT BE THE WAY TO RETRIEVE THE UID FOR DATABASE!!!
    if (userCredential.user != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Log in Successful')));
      return userCredential;
    }
    return userCredential;
  }

  /* Non-google sign up / login */
  static signupUser(String email, String password, BuildContext context) async {
    /* try to create user */
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Access the uid of the newly created user
      String uid = userCredential.user!.uid;

      // Access the uid of the newly created user
      String username = userCredential.user!.email!;

      // Step 3: Trigger Cloud Function to create user in the cloud
      await addUserCloud(uid, username);

      await FirebaseAuth.instance.currentUser!.updateEmail(email);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registration Successful')));
      goToLogin(context);
    }
    /* if error occurred when getting user */
    on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password Provided is too weak')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email Provided already Exists')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  static Future<void> addUserCloud(String uid, String username) async {
    try {
      final response = await http.post(
        /* cloud function link that handles adding login info to the database */
        Uri.parse(
            'https://us-central1-planar-beach-404723.cloudfunctions.net/function-2'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        /* parameters to pass to the post request and then used to insert into database. */
        body: jsonEncode(<String, String>{
          'uid': uid,
          'username': username,
        }), // Convert the map to a JSON-encoded string
      );

      if (response.statusCode == 200) {
        print('Response from Cloud Function: ${response.body}');
      } else {
        print(
            'Failed to call Cloud Function. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error calling Cloud Function: $e');
    }
  }

  static signinUser(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('You are Logged in')));
      goToTasks(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user Found with this Email')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Password did not match')));
      }
    }
  }
}
