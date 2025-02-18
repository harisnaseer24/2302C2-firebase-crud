import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
            }, child: Text("Register"))
          ],
        ),
      )
      ,
    );
  }
}