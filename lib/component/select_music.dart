import 'package:flutter/material.dart';
import 'package:project_ai/component/getMusic.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';


class selectmusic extends StatefulWidget {
   selectmusic({super.key});

  @override
  State<selectmusic> createState() => _selectmusicState();
}

class _selectmusicState extends State<selectmusic> {
   Map<String,List> items = {"開心愉悅":["assets/Icons/smily.png"," chill ","活力pop"]
     ,"專注工作":["assets/Icons/brain.png"," Jazz ","Jazz"]
     ,"放鬆療癒":["assets/Icons/lotus.png","relaxing music official track","LoFi/Acoustic"]
     ,"夜晚靜心":["assets/Icons/moon.png","sleep music ambient track","Ambient"]
     ,"運動激勵":["assets/Icons/heart-rate.png","Hip pop","Workout"]
     ,"療癒低潮":["assets/Icons/heavy-rain.png","healing song lyrics","chill Balled"]
   };

  //選擇的音樂類型
   final ValueNotifier<String> _category=  ValueNotifier("");

   //建立Youtubem服務
   String  get Apikey => dotenv.env['Youtube_API_KEY'] ?? "error";
   String selectedCategory = "";
   final ValueNotifier<List> _result = ValueNotifier([]);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Row(
            children: [
              SizedBox(width: 15,),
              Icon(Icons.headphones,
                size: 30,
              ),
              SizedBox(width: 8,),
              Column(
                children: [
                  Text("MOOD BOOSTER",
                    style: TextStyle(color: Colors.blue[200]),
                  ),
                  Text('情緒音樂電台',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 30,),
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
            padding: EdgeInsets.only(top: 30),
            child:
            Column(
              children: [
                Text("挑選目前的情緒，AI幫你找到最適合的\n曲目",
                  style: TextStyle(color: Colors.grey) ,
                ),
                SizedBox(height: 15,),
                GridView.count(
                  //要佔幾行
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(6),
                  //方格比例
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    for(var entry in items.entries)
                      Container(
                        decoration: BoxDecoration(border: Border.all(
                          color: Colors.black.withAlpha(5),
                        )
                        ),
                        child:
                          Material(
                            color: selectedCategory == entry.value[0]?
                                Colors.blue.withAlpha(50):Colors.white,
                            child:
                            InkWell(
                              onTap:() async {
                                setState(() {
                                  selectedCategory = entry.value[0];
                                });
                                // 總共要做兩件事
                                _result.value =[];
                                _category.value = entry.value[1]; // 1.取得使用者點選之類型
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                      content: SizedBox(
                                          width: 150,
                                          height: 150,
                                          child:  Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 80,
                                                  width: 80,
                                                  child: CircularProgressIndicator(),
                                                ),
                                                SizedBox(height: 20,),
                                                Text("正在搜尋...",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 20
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                      ),
                                    )
                                );
                                try {

                                  final searchResult = await getmusic().searchMusic(_category.value, Apikey);


                                  if (mounted) {
                                    Navigator.of(context).pop();
                                  }

                                  // 4. 更新結果資料
                                  _result.value = searchResult;

                                } catch (e) {
                                  // 如果出錯，也要記得關閉對話框，否則 App 會卡死
                                  if (mounted) Navigator.of(context).pop();
                                  print("搜尋出錯: $e");
                                }

                              },
                              child:
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(entry.value[0],
                                    width: 45, ),
                                  SizedBox(height: 10,),
                                  Text(entry.key,style: TextStyle(color: Colors.black),),
                                  SizedBox(height: 2,),
                                  Text(entry.value[2],style: TextStyle(color: Colors.grey),),
                                ],
                              ),
                            ) ,
                          )
                      ),
                  ],
                ),
              ],
            )
        ),

    ValueListenableBuilder(
        valueListenable:_category ,
        builder: (context, categories, child){
            if (categories=="")
              return
                Container(
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
              padding: EdgeInsets.symmetric(vertical: 90,horizontal: 50),
              margin: EdgeInsets.fromLTRB(20, 0, 20,30),
              child:
              Center(
                child:
                Text("選擇情緒，開始播放今日的心情歌單",
                  textAlign: TextAlign.center,
                  style:TextStyle(color: Colors.grey) ,
                ),
              ),
            );
        return ValueListenableBuilder(
            valueListenable: _result,
            builder: (context, result, child){
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
               child:  ListView.separated(
                 shrinkWrap: true,
                 physics: NeverScrollableScrollPhysics(),
                 itemCount: result.length,
                 separatorBuilder: (context, index) => Divider(),
                 itemBuilder: (context,index){
                   final item = result[index];
                   return ListTile(
                     title: Text(item[0]
                       ,style: TextStyle(color: Colors.black,fontSize: 20),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                     ),
                     leading: Container(
                       child: Image.network(item[1].toString(),
                         fit: BoxFit.cover,
                         width: 60,
                         height: 50,
                       ),
                       padding: EdgeInsetsGeometry.symmetric(vertical: 8,horizontal: 5),
                     ),
                     subtitle: Text(item[3].toString(),
                       style: TextStyle(color: Colors.grey),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                     ),
                     trailing: IconButton(
                       onPressed: () async {
                       final Uri url = Uri.parse(item[2].toString());
                       if (await canLaunchUrl(url)) {
                         await launchUrl(url, mode: LaunchMode.externalApplication,);
                       } else {
                         throw 'Could not launch $url';
                       }
                     }, icon: Icon(Icons.play_arrow),),
                   );
                 },
               ),
             );
            },
          );
          }
        )
      ],
    );
  }
}
