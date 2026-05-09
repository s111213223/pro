import "package:flutter/material.dart";
import 'package:project_ai/component/analyzeFood.dart';
import 'package:project_ai/Page/temp_result.dart';


class Inputmeal extends StatelessWidget {
  const Inputmeal({super.key});


  Future<void> _gen(BuildContext context,String userprompt)async{
    try{
      String result = await analyzefoodphoto().analyzefoodbytext(userprompt);
      Navigator.pop(context);
      print(result);
      Navigator.push(context,
          MaterialPageRoute(builder: (context)=>photoresult(result: result, photo:null))
      );
    }
    catch(e){
      print("error");
    }
  }


  @override
  Widget build(BuildContext context) {
    final nameController_one = TextEditingController();
    final nameController_two = TextEditingController();
    return
      SingleChildScrollView(
          padding: EdgeInsets.all(30),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("食物名稱"),
              SizedBox(height: 10,),
              TextField(
                controller: nameController_one,
                maxLines: 1,
                decoration: InputDecoration(
                    hintText: "例如：滷肉飯、咖哩飯",
                    border: OutlineInputBorder()
                ),
              ),
              SizedBox(height: 10,),
              Text("份量(選填)"),
              SizedBox(height: 10,),
              TextField(
                controller: nameController_two,
                maxLines: 1,
                decoration: InputDecoration(
                    hintText: "例如 一份",
                    border: OutlineInputBorder()
                ),
              ),
              SizedBox(height: 10,),
              TextButton(
                onPressed: (){
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
                                  Text("正在分析中...",
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
                  _gen(context,nameController_one.toString()+nameController_two.toString());
                },
                child: Text("開始評估熱量"
                  ,style: TextStyle(
                      color: Colors.black
                  ),
                ),
                style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.withAlpha(70),
                    minimumSize: Size(double.infinity, 20),
                    padding: EdgeInsets.all(10)
                ),
              )
            ],
          )
      );

  }
}
