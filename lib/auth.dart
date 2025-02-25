import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crud/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController emailController=TextEditingController();
  TextEditingController passController=TextEditingController();
  TextEditingController usernameController=TextEditingController();

  var users= FirebaseFirestore.instance.collection('users');
signup() async{
  try {
  final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: emailController.text,
    password: passController.text,
  );
  await users.add({
    'email':emailController.text,
    'password':passController.text,
    'username':usernameController.text,
    'id':credential.user?.uid,
  });
print("user created successfuly");
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User created successfuly"),));
    Navigator.pushNamed(context, '/login');

} on FirebaseAuthException catch (e) {
  if (e.code == 'weak-password') {
    print('The password provided is too weak.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The password provided is too weak."),));
  } else if (e.code == 'email-already-in-use') {
    print('The account already exists for that email.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The account already exists for that email."),));
  }
} catch (e) {
  print(e);
}
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Now'),
      ),
      body: 
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ListView(
          children: [
            SizedBox(height: 20,),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                label: Text("Enter username"),
                hintText: "Username"
               ,border: OutlineInputBorder(),

              ),
            ),
             SizedBox(height: 20,),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                label: Text("Enter email"),
                hintText: "Email"
               ,border: OutlineInputBorder(),

              ),
            ),
             SizedBox(height: 20,),
            TextField(
              controller: passController,
              decoration: InputDecoration(
                label: Text("Enter password"),
                hintText: "Password"
               ,border: OutlineInputBorder(),

              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: (){
              signup();
            }, child: Text("Register")),

            SizedBox(height: 20,),
             GestureDetector(onTap: (){
             Navigator.pushNamed(context, "/login");
            }, child: Text("Already a user? Login now"))
          ],
        ),
      )
      ,
    );
  }
}


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
    TextEditingController emailController=TextEditingController();
  TextEditingController passController=TextEditingController();

  login()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
  final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: emailController.text,
    password: passController.text
  );

// var user= 
    prefs.setBool("isLoggedIn", true);
    prefs.setString("email", emailController.text);


     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signed in as ${emailController.text}"),));
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyProducts()));

} on FirebaseAuthException catch (e) {
    prefs.setBool("isLoggedIn", false);
    print(e.code);

  if (e.code == 'user-not-found') {
    print('No user found for that email.');
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No user found for that email. Please create an account first."),));
     Navigator.pushNamed(context, '/signup');
  }
  else if (e.code == 'wrong-password') {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("fuck u."),));
    print('Wrong password provided for that user.');
     Navigator.pushNamed(context, '/signup');
  }
   else if (e.code == 'invalid-credential') {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not a user jani."),));
    print('Wrong password provided for that user.');
     Navigator.pushNamed(context, '/signup');
  }
}
  }

  @override
  initState(){
     setDef()async{
       final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool("isLoggedIn", false);
     }
     setDef();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Now'),
      ),
      body: 
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ListView(
          children: [
             SizedBox(height: 20,),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                label: Text("Enter email"),
                hintText: "Email"
               ,border: OutlineInputBorder(),
              ),
            ),
             SizedBox(height: 20,),
            TextField(
              controller: passController,
              decoration: InputDecoration(
                label: Text("Enter password"),
                hintText: "Password"
               ,border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: (){
              login();
            }, child: Text("Login")),
             SizedBox(height: 20,),
            Center(
              child: TextButton(onPressed: (){
               Navigator.pushNamed(context, "/signup");
              }, child: Text("Not a user? Click here to register")),
            )
          ],
        ),
      )
      ,
    );
  }
}
