import 'package:flutter/material.dart';

class UserStats extends StatelessWidget{
  final String count;
  final String label;

  const UserStats( {
    super.key,
    required this.count,
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(count,
        style: TextStyle(fontSize: 48, fontFamily: 'Serif', color: Colors.grey, height:1.0,),),
        const SizedBox(height:4),
        Text(label,
        textAlign: TextAlign.center, 
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:Colors.black, height:1.1,))
      ],
    );
  }
}