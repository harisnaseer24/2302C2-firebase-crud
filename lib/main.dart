import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crud/addproducts.dart';
import 'package:firebase_crud/auth.dart';
import 'package:firebase_crud/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
final SharedPreferences prefs = await SharedPreferences.getInstance();
bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
bool isAdmin = prefs.getBool("isAdmin") ?? false;
print(isLoggedIn);


  runApp(MyApp(isLoggedIn:isLoggedIn,isAdmin:isAdmin));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isAdmin;

  const MyApp({super.key,required this.isLoggedIn, required this.isAdmin});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
    
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Login(),
      routes: {
        '/signup':(context)=>Signup(),
       
        '/products':(context)=>isLoggedIn ?MyProducts() : Login(),
        '/add':(context)=>(isLoggedIn && isAdmin) ? AddProductPage() : Login(),
      },
    );
  }
}
 
class MyProducts extends StatefulWidget {
  const MyProducts({super.key});


  @override
  State<MyProducts> createState() => _MyProductsState();
}


class _MyProductsState extends State<MyProducts> {
String email="";
String username='';
getUserDetails()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    setState(() {
      
    email= prefs.getString("email")!;
    username= prefs.getString("username")!;
    print(email);
    });
}



CollectionReference products= FirebaseFirestore.instance.collection('products');

 _deleteProduct(String id)async{
try {
  await products.doc(id).delete();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product deleted successfully"),));
} catch (e) {
  print(e);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fail to delete product"),));
}
 }
 void _editProduct(String id,String title,String description,double price){

  TextEditingController titleController=TextEditingController(text: title);
  TextEditingController descController=TextEditingController(text: description);
  TextEditingController priceController=TextEditingController(text: price.toString());

  showDialog(context: context, builder: (context){
return
AlertDialog(
  title: Text("Edit $title"),
  content: Column(
     mainAxisSize: MainAxisSize.min,
    children: [
      TextField(
        controller: titleController,
        decoration: InputDecoration(
          labelText: "Title"
        ),),
         TextField(
        controller: descController,
        decoration: InputDecoration(
          labelText: "Description"
        ),
      ),
       TextField(
        controller: priceController,
        decoration: InputDecoration(
          labelText: "Price"
        ),)
    ],
  ),
  
  
  actions: [
    TextButton(onPressed: () {
      Navigator.pop(context);
    }, child: Text("Cancel")),

    TextButton(onPressed: () async{
      try {
        await products.doc(id).update({
          'title':titleController.text,
          'description':descController.text,
          'price':double.parse(priceController.text)
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product updated successfully"),));
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fail to update product"),));
      }
    }, child: Text("Update"))
  ],);
  });


 }
  @override
   initState(){
    getUserDetails();
   }
  Widget build(BuildContext context) {
    return Scaffold(
   
      appBar: AppBar(
        title: Text("Products"),
        actions: [
          IconButton(onPressed: ()async{
         await FirebaseAuth.instance.signOut();
   final SharedPreferences prefs = await SharedPreferences.getInstance();
          
          prefs.setBool("isLoggedIn", false);
          prefs.remove("email");
          

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
          }, icon: Icon(Icons.logout))
        
        ,
        Text(username)
        ],

      ),
      body: Center(
        child: StreamBuilder(stream: products.snapshots(), builder: (context,snapshot){
         
        if (snapshot.connectionState == ConnectionState.active) {
  
          if (snapshot.hasData) {

            return ListView.builder(itemBuilder: (context,index){

              var product=snapshot.data!.docs[index];
        return ListTile(
          title: Text(product['title']),
          subtitle: Text(email),
          leading: CircleAvatar(
            child: Image.memory(base64Decode(product['image'])),),
            trailing:
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
             IconButton(onPressed: () {
              _editProduct(product.id, product['title'],product['description'],product['price']);
            },
              icon:Icon(Icons.edit,color: Colors.blue,),
            ),
              IconButton(onPressed: () {
              _deleteProduct(product.id);
            },
              icon:Icon(Icons.delete,color: Colors.red,),
            ),
            ],)
             
        );
            },
            itemCount: snapshot.data!.docs.length,);
          } else {
             return Text("No data found");
          }
        } else {
          return SpinKitDancingSquare(color: Colors.blueAccent,); 
          
        }
        }),
      ),
    );
  }
}