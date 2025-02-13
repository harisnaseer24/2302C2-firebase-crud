import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crud/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyProducts(),
    );
  }
}

class MyProducts extends StatefulWidget {
  const MyProducts({super.key});

  @override
  State<MyProducts> createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),

      ),
      body: Center(
        child: StreamBuilder(stream: products.snapshots(), builder: (context,snapshot){
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return ListView.builder(itemBuilder: (context,index){
        return ListTile(
          title: Text(snapshot.data!.docs[index]['title']),
          subtitle: Text(snapshot.data!.docs[index]['description']),
          leading: CircleAvatar(
            child: Text(snapshot.data!.docs[index]['price'].toString()),),
            trailing: IconButton(onPressed: () {
              _deleteProduct(snapshot.data!.docs[index].id);
            },
              icon:Icon(Icons.delete),
            ),
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