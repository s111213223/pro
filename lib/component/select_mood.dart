import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_ai/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



//mood.dart 可刪掉




class selectmood extends StatefulWidget {
   selectmood({super.key});

  @override
  State<selectmood> createState() => _selectmoodState();
}

class _selectmoodState extends State<selectmood> {
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

  final ValueNotifier<List<dynamic>> _userMessageNotifier = ValueNotifier<List<dynamic>>([]);

  String _userEmoji = "";

   final SupabaseAuth _supabaseService = SupabaseAuth();
   String emojiCategory = '';
   final nameController = TextEditingController();

  @override
   void dispose(){
     nameController.dispose();
     super.dispose();
   }

   Future loadData()async{
     final data =await _supabaseService.fetchUsermessage();
     List<List<dynamic>> tempList = [];
     for(int i=0; i<data.length;i++){
       final temp = [data[i]['emoji'],data[i]['comment']];
       tempList.add(temp);
     }
     _userMessageNotifier.value = tempList;
     print(_userMessageNotifier.value);
   }
  @override
  void initState(){
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
      Container(
        child: Row(
          children: [
            SizedBox(width: 15,),
            Icon(Icons.mood,
              size: 30,
            ),
            SizedBox(width: 3,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("情緒留言板",
                  style: TextStyle(color: Colors.blue[200],
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
                ),
                Text('分享你的心情，為他人加油打氣',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14
                  ),
                ),
              ],
            ),
            SizedBox(width: 15,),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:
                      Padding(padding: EdgeInsets.all(5),
                        child:
                          Text("糖尿病社群",
                          style: TextStyle(fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                      ),
                )
              ],
            )
          ],
        ),
      ),
      SizedBox(height: 30,),



      // 需要另外開一個頁面去寫
      Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius:2,
                  blurRadius: 2,
                )
              ]
          ),

          margin: EdgeInsets.fromLTRB(20, 0, 20,30),
          padding: EdgeInsets.only(top: 10),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width: 10,), //需要包在ROW或Column才可以有空白的效果
                  Text("選擇情緒",
                    style: TextStyle(color: Colors.black,
                        fontWeight: FontWeight.bold) ,
                  ),
                ],
              ),
              SizedBox(height: 15,),
              GridView.count(
                //要佔幾行
                crossAxisCount: 6,
                shrinkWrap: true,
                padding: EdgeInsets.all(6),
                //方格比例
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  for(var entry in items.entries)
                    Container(
                      decoration: BoxDecoration(border: Border.all(
                        color: Colors.black.withAlpha(9),
                      )
                      ),
                      child:
                          Material(
                            color: emojiCategory == entry.value? Colors.blue.withAlpha(90):Colors.white,
                            child:
                            InkWell(
                              onTap: (){
                                _userEmoji='';
                                _userEmoji  = entry.value;
                                setState(() {
                                  emojiCategory = entry.value;
                                });
                              },
                              child:
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(entry.value,style:
                                  TextStyle(fontSize: 30),),
                                ],
                              ),
                            ),
                          )
                    ),
                ],
              ),
              SizedBox(height: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 10,),
                      Text("分享你的心情",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  //final nameController = TextEditingController();
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      maxLength: 500,
                      maxLines: null,
                      controller: nameController,
                      decoration: InputDecoration(
                          hintText: "寫下你想說的話...",
                          border: OutlineInputBorder()
                      ),
                    ),
                  ),
                  SizedBox(height: 5,),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 50,vertical: 10),
                      child:
                      TextButton(
                          style:TextButton.styleFrom(
                              alignment: Alignment.center,
                              backgroundColor: Colors.blue.withAlpha(70),
                              minimumSize: Size(300, 20),
                              padding: EdgeInsets.all(10)
                          ),
                          onPressed:() async{
                            if(nameController.text.isNotEmpty && _userEmoji.isNotEmpty){
                              //總共要做兩件事情 1.將留言納入字典(_userMesssage) 2.留言數+1
                                       //前提:取得使用者輸入內容  1.表情 2.留言

                             _userMessageNotifier.value = [
                               ..._userMessageNotifier.value, //更新內部
                               [
                                _userEmoji,
                                 nameController.text
                               ]
                             ];
                             print(_userMessageNotifier.value);
                             await _supabaseService.upLoadMessage([_userEmoji,nameController.text]);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("已儲存至雲端")));

                             nameController.clear();
                             Focus.of(context).unfocus();
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("請填寫訊息或選擇表情")));
                            }

                          },
                          child:
                          Text("送出",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          )
                      ),
                    )
                ],
              )
            ],
          )
      ),

      ValueListenableBuilder(
          valueListenable: _userMessageNotifier,
          builder: (context,currentMessage,child){
            if(currentMessage.isEmpty){
              return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 2,
                          blurRadius: 2,
                        )
                      ]
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                  margin: EdgeInsets.fromLTRB(20, 0, 20,30),
                  child:
                  Center(
                    child:
                      Text("目前尚無留言",
                        textAlign: TextAlign.center,
                        style:TextStyle(color: Colors.grey) ,
                      ),
                    )
              );
            }
            return
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: currentMessage.length,
                itemBuilder: (context,index){
                  var entry = currentMessage[index];
                  return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 2,
                              blurRadius: 2,
                            )
                          ]
                      ),
                      padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                      margin: EdgeInsets.fromLTRB(20, 0, 20,20),
                    child:
                      ListTile(
                      title: Text("匿名",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
                      leading: Container(
                      child: Text(entry[0],style: TextStyle(fontSize: 30),),
                      padding: EdgeInsets.symmetric(vertical: 8,horizontal: 5),
                      ),
                      subtitle: Text(entry[1].toString()),
                      )
                    );
                  },
                );

         },
        )
      ],
    );
  }
}




