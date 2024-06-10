
import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  String message;
   ErrorPage({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(

 child:Text('Errormessage $message',style: TextStyle(fontSize: 20,color: Colors.black),),

    ));
  }
}
