import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: "6809 Emulator/Debugger",
        debugShowCheckedModeBanner: true,  //hide the 'debug' in the top right of the window
        home: Scaffold(body:Center(child:Text("Hello World!")))
    );
  }
}