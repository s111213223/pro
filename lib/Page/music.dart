import 'package:flutter/material.dart';
import 'package:project_ai/Page/mood.dart';
import 'package:project_ai/component/drawer.dart';
import 'package:project_ai/component/select_mood.dart';
import 'package:project_ai/component/select_music.dart';

class showMusic extends StatefulWidget {
  const showMusic({super.key});

  @override
  State<showMusic> createState() => _showMusicState();
}

class _showMusicState extends State<showMusic> {

  final ValueNotifier<int>_currentPage=ValueNotifier(0);

  Widget _buildMusic(BuildContext context, int _currentPage, Widget? child){
    return selectmusic();
  }

  Widget _buildMood(BuildContext context, int _currentPage, Widget? child){
    return  selectmood();
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.blue[400],
          automaticallyImplyLeading: false,
          title: Text("療癒",
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
                Padding(padding: EdgeInsetsGeometry.symmetric(vertical: 15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: (){
                    _currentPage.value=0;
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black
                  ) ,
                  child: Row(
                    children: [
                      Icon(Icons.headphones),
                      Text("音樂推薦　",textAlign: TextAlign.center),
                    ],
                  ),
                ),
                    SizedBox(width: 20,),
                    ElevatedButton(onPressed: (){
                      _currentPage.value=1;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black
                    ) ,
                    child: Row(
                      children:[
                        Icon(Icons.favorite),
                        Text("情緒留言板",textAlign: TextAlign.center),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    )
                    )
                  ],
                  //mainAxisAlignment: MainAxisAlignment.center,
                ),
                SizedBox(height: 30,),
                Container(
                  child:
                  ValueListenableBuilder<int>(
                  valueListenable: _currentPage,
                  builder: (context,pageIndex, child){
                    if(pageIndex==0){
                      return _buildMusic(context, pageIndex, child);
                    }
                    if(pageIndex==1){
                      return _buildMood(context, pageIndex, child);
                    }
                    return SizedBox();
                  },
                ),
                )
              ],
            )
        )
    );
  }
}