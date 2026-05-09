import 'package:flutter/material.dart';
import 'package:project_ai/Page/mood.dart';
import 'package:project_ai/Page/music.dart';
import 'package:project_ai/Page/userdata.dart';
import 'package:project_ai/Page/Navgiation.dart';
import 'package:project_ai/component/image.dart';
import 'package:project_ai/Page/AI_chat.dart';

// 跟照片有關的套件
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class homebuttonbar extends StatelessWidget {
  const homebuttonbar({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: EdgeInsets.symmetric(horizontal:12),
      height: 80 ,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black12
        ),
        color:Colors.white,
      ),
      margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              IconButton(
                onPressed: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context)=> ChatScreen()));
                },
                icon: Icon(Icons.messenger_outlined),
                color:Colors.black,
                iconSize: 30,
              ),
              Text("AI對話",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),)
            ],
          ),
          Column(
            children: [
              IconButton(
                onPressed: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder:(context)=>image()));
                },
                icon: Icon(Icons.camera_alt),
                color: Colors.black,
                iconSize: 30,
              ),
              Text("AI辨識",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),)
            ],
          ),
          Column(
            children: [
              IconButton(
                onPressed: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => userdata()));
                },
                tooltip: "報告", //提示訊息
                icon: Icon(Icons.data_thresholding),
                color: Colors.black,
                iconSize: 30,
              ),
              Text("紀錄",
              style: TextStyle(
                color:Colors.black,
                fontWeight: FontWeight.bold,
              ),
              )
            ],
          ),
          Column(
            children: [
              IconButton(
                onPressed: (){Navigator.push(
                    context,MaterialPageRoute(builder: (context)=> showMusic()));
                },
                icon: Icon(Icons.mood),
                color: Colors.black,
                iconSize: 30,
              ),
              Text("療育",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),)
            ],
          )
          
        ],
      ),
    );
  }
}
