import 'package:flutter/material.dart';
import 'package:project_ai/Page/music.dart';
import 'package:project_ai/component/drawer.dart';

class showMood extends StatefulWidget {
  const showMood({super.key});

  @override
  State<showMood> createState() => _showMoodState();
}

class _showMoodState extends State<showMood> {



  Map<String,String> items = {"微笑":"😊"
    ,"淚":"😢"
    ,"睡著":"😴"
    ,"傲慢":"😤"
    ,"鬆了口氣":"😌"
    ,"思考":"🤔"
    ,"花癡":"😍"
    ,"慶祝":"🥳"
    ,"墨鏡":"😎"
    ,"哭":"😭"
    ,"生氣":"😡"
    ,"抱抱":"🤗"
    };

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        automaticallyImplyLeading: false,
        title: Text("情緒留言板",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold
          ),
        ),
          leading: Builder(builder: (context)=>
              IconButton(onPressed:(){
              Scaffold.of(context).openDrawer();}
              ,icon: Icon(Icons.sort)
          )
        ),
      ),
      drawer: Mydrawer(),//SingleChildScrollView
      body: SingleChildScrollView(
        child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>showMusic()));
                }, child: Row(
                  children: [
                    Icon(Icons.headphones),
                    Text("音樂推薦　",
                    textAlign: TextAlign.center,),
                    ],
                  ),
                ),
                  SizedBox(width: 20,),
                  ElevatedButton(onPressed: (){},
                  child: Row(
                    children: [
                      Icon(Icons.favorite),
                      Text("情緒留言板"),
                      ],
                    )
                  )
                ],
              ),
              SizedBox(height: 30,),


              //
            ],
          )
      )
    );
  }
}
