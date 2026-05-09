import 'package:flutter/material.dart';
import 'package:project_ai/Page/Inputphoto.dart';
import 'package:project_ai/Page/foodLog.dart';
import 'dart:io';
import 'package:project_ai/component/foodCard.dart';
import 'package:project_ai/component/food_item.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart'as gai;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openai_dart/openai_dart.dart' hide Container;






final ValueNotifier<List<FoodItem>> _foodItemsNotifier = ValueNotifier([]);

class photoresult extends StatefulWidget {

    var result,photo;
   photoresult({super.key,required this.result,required this.photo});

    // final model = gai.GenerativeModel(
    //     model: 'gemini-embedding-001',
    //     apiKey: dotenv.env['Gemini_API_KEY'] ?? ""
    // );
  @override
  State<photoresult> createState() => _photoresultState();
}

class _photoresultState extends State<photoresult> {

  bool _isloading = true;

  @override
  void initState() {
    super.initState();
    photoAIresult();
  }

  Future<void> photoAIresult()async{
    if(widget.result != null){
      try {
        List<String> lines = widget.result.split('\n');
        List<FoodItem> newItems = [];

        for (String line in lines) {
          List<String> parts = line.split('|');

          if (parts.length >= 2) {
            String name = parts[0].trim();
            int portion = int.tryParse(parts[1].trim()) ?? 0;
            // int calories =  int.tryParse(parts[2].trim()) ?? 0;

            // final content = gai.Content.text(name);
            // final result = await widget.model.embedContent(content);
            // final vector = result.embedding.values;
            final client = OpenAIClient.withApiKey( dotenv.env['openai_key'] ?? "error");
            final result_open = await client.embeddings.create(
                EmbeddingRequest(
                  model: 'text-embedding-3-large',
                  input: EmbeddingInput.text(name),
                  dimensions: 3072
                ),
            );
            final vector = result_open.firstEmbedding.take(3072).toList();
            client.close();
            print(vector);
            final List<dynamic> response = await Supabase.instance.client.rpc(
              'match_food_auto',
              params: {'query_embedding': vector, 'match_threshold': 0.1},
            );


            if (response.isNotEmpty) {
              final data = response[0];
              print("資料$data");

              newItems.add(FoodItem(
                name: name,
                weight: portion,
                calories: ((data['kcal'] * portion) / 100).round(),
                carbs: (data['carbohydrate'] * portion) / 100,
                sugar: (data['sugar'] * portion) / 100,
                fiber: (data['fiber'] * portion) / 100,
                protein: (data['protein']* portion) / 100,
                similarity: data['similarity'],
                caloriesprer100: data['kcal'],
              ));

              print("卡路里:${data['kcal']}");
              print("碳水化合物:${data['carbohydrate']}");
              print("糖:${data['sugar']}");
              print("纖維:${data['fiber']}");
              print("蛋白質:${data['protein']}");
              print("\n");
            }
          }
        }

        _foodItemsNotifier.value = newItems;
      }
      catch(e){
        print("錯誤 ${e.toString()}");
      }
      finally{
        setState(() {
          _isloading= false;
        });
      }

    }
  }

  int  _calculateTotal(List<FoodItem> items) => items.fold(0, (sum, i) => sum + i.allcalories);

  Future<void> _uploadAndSaveToSupabase() async {
    // 1. 開啟載入狀態，避免使用者重複點擊按鈕
    setState(() => _isloading = true);

    try {
      final List<FoodItem> items = _foodItemsNotifier.value;
      if (items.isEmpty) return;

      String uploadedImageUrl = "";

      // 第一步：處理圖片上傳 (Supabase Storage)
      if (widget.photo != null) {
        final file = File(widget.photo!.path);
        // 產生唯一檔名，建議加上使用者識別碼或時間戳記
        final fileName = "meal_${DateTime.now().millisecondsSinceEpoch}.jpg";

        // 上傳到名為 'food-images' 的 Bucket (請確保你在 Supabase 已建立此 Bucket)
        await Supabase.instance.client.storage
            .from('diet_log')
            .upload(fileName, file);

        // 取得圖片的公開訪問 URL
        uploadedImageUrl = Supabase.instance.client.storage
            .from('diet_log')
            .getPublicUrl(fileName);
      }

      // 第二步：計算所有食材的營養總和 (糖尿病分析核心)
      // 這裡使用 .fold 進行累加，並處理可能的 null 值
      int totalCalories = items.fold(0, (sum, item) => sum + item.allcalories);
      int totalWeights = items.fold(0, (sum, item) => sum + item.weight);
      double totalCarbs = items.fold(0.0, (sum, item) => sum + (item.carbs ?? 0.0));
      double totalFiber = items.fold(0.0, (sum, item) => sum + (item.fiber ?? 0.0));
      double totalProtein = items.fold(0.0, (sum, item) => sum + (item.protein ?? 0.0));
      double totalSugar = items.fold(0.0, (sum, item) => sum + (item.sugar ?? 0.0));

      // 組合名稱字串 (例如：白飯、青菜...)
      String combinedNames = items.map((e) => e.name).join('、');

      // 第三步：寫入資料庫 (Supabase Database)
      // 欄位名稱必須與你在 Supabase 設定的完全一致
      await Supabase.instance.client.from('diet_log').insert({
        'name': combinedNames,
        'calories': totalCalories,
        'carbs': totalCarbs,
        'fiber': totalFiber,
        'protein': totalProtein,
        'sugar': totalSugar,
        'image_url': uploadedImageUrl,
        'created_at': DateTime.now().toIso8601String(), // 存入 ISO 格式的時間字串
      });

      // // 第四步：同步更新本地 newList (選填，視你的 foodlog 讀取邏輯而定)
      // // 我們建立一個帶有圖片路徑的摘要物件傳給下一頁顯示
      // FoodItem summary = FoodItem(
      //   name: combinedNames,
      //   calories: totalCalories,
      //   carbs: totalCarbs,
      //   fiber: totalFiber,
      //   weight: totalWeights,
      //   imagePath: widget.photo?.path, // 傳遞本地路徑讓 foodlog 立即顯示，不需等待下載
      // );
      // newList.add(summary);

      // 成功後跳轉至紀錄頁面
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  foodlog()));
      }

    } catch (e) {
      print("❌ 上傳與儲存發生錯誤: $e");
      // 可以在這裡加入 ScaffoldMessenger 顯示錯誤提示給使用者
    } finally {
      if (mounted) setState(() => _isloading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_isloading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("處理中請稍後...", style: TextStyle(color: Colors.blueGrey)),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("分析結果",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[400],
      ),
      body: ValueListenableBuilder(
          valueListenable: _foodItemsNotifier,
          builder: (context, foodlist, child){
            int total = _calculateTotal(foodlist);
            return  SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 30,vertical: 15),
                          height: 200,
                          //width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: widget.photo!=null? Image.file(File(widget.photo.path),fit:BoxFit.contain,height: 200,width: 350,):Container(color: Colors.black,width: 350,height: 200,
                                  child: Center(child: Text("暫無照片",style: TextStyle(color: Colors.white),),
                                  )
                              )
                          ),
                        ),
                        Positioned(
                            left: 39,
                            bottom: 25,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black12
                                        )
                                      ]
                                  ),
                                  child:
                                  Column(
                                    children: [
                                      Text("總熱量估算",style: TextStyle(color: Colors.black,
                                          fontSize: 12
                                      ),
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(total.toString(),
                                            style: TextStyle(color: Colors.black,fontSize: 18),),
                                          SizedBox(height: 8,),
                                          Text("Kcal",style: TextStyle(color: Colors.black,fontSize: 15),)
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                        )
                      ],
                    ),
                    ...foodlist.asMap().entries.map((entry) {
                      return foodcard(
                        index: entry.key,
                        item: entry.value,
                        onChanged: (updatedItem) {
                          _foodItemsNotifier.value = List.from(_foodItemsNotifier.value);
                          setState(() {
                            total = _calculateTotal(_foodItemsNotifier.value);
                          });
                        },
                        onDelete: () {
                          var newList = List<FoodItem>.from(_foodItemsNotifier.value);
                          newList.removeAt(entry.key);
                          _foodItemsNotifier.value = newList;
                        },
                      );
                    }).toList(),
                    //Text(result),
                    // 新增按鈕
                    Container(
                      margin: EdgeInsets.fromLTRB(25, 5, 25, 5),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child:  ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                          ),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,

                        ),
                        onPressed: () {
                          _foodItemsNotifier.value = [
                            ..._foodItemsNotifier.value,
                            FoodItem(name: "新項目", weight: 0, calories: 0)
                          ];
                        },
                        child:  Text("+ 新增品項",style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(25, 5, 25, 5),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child:  ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                          ),
                          backgroundColor: Colors.blue[400],
                          foregroundColor: Colors.black,

                        ),
                        onPressed: (){
                          _isloading? null :_uploadAndSaveToSupabase();
                          // final List<FoodItem> single = _foodItemsNotifier.value;
                          //
                          // int totalcal= _calculateTotal(single);
                          // int num=0;
                          // String totalname="";
                          // for(var temp in single){
                          //   num++;
                          //   totalname = totalname +temp.name + "、";
                          //   if(num>=3){
                          //     totalname = totalname.substring(0,totalname.length-1)+"...";
                          //    break;
                          //   }
                          // }
                          // FoodItem  summary =FoodItem(
                          //     name: totalname,
                          //     weight: 0 ,
                          //     calories: totalcal
                          // );
                          // newList.add(summary);
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>foodlog()));
                        },
                        child: _isloading
                            ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        ):
                        Text("儲存至日記",style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ],
                )
            );
          }
      )
      ,
    );
  }
}
