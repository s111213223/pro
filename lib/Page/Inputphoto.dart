import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_ai/Page/temp_result.dart';
import 'dart:io';
import 'package:project_ai/component/analyzeFood.dart';

class inputphoto extends StatelessWidget {

  final ValueNotifier<XFile?>imageFileNotifier;
   inputphoto({super.key, required this.imageFileNotifier});

  final ImagePicker _imagePicker = ImagePicker(); //建立ImagePicker

   //取得照片
   Future<void>_getImage(BuildContext context,ImageSource imageSource) async {
     XFile? imgfile = await _imagePicker.pickImage(source: imageSource);
     imageFileNotifier.value = imgfile;

     if(imgfile!=null){
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

       try{
         String result = await analyzefoodphoto().analyzefood(imgfile);
         Navigator.pop(context);
         Navigator.push(context,
             MaterialPageRoute(builder: (context)=>photoresult(result: result, photo: imgfile))
         );
       }
       catch(e){
         print("error");
       }
     }


   }

   //放出照片
   Widget _imageBuilder(BuildContext context,XFile? imageFile, Widget? child){
     final wid = imageFile == null ?
     Center(
       child: Container(
         margin: EdgeInsets.only(top:70),
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(20),
             border: Border(
             ),
             boxShadow: [
               BoxShadow(color: Colors.black12),

             ]
         ),
         child: TextButton(
             style: TextButton.styleFrom(
                 backgroundColor: Colors.blue[200],
                 padding: EdgeInsets.fromLTRB(50, 50, 50, 50),
                 shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(20)
                 ),
             ),
             onPressed: (){
                _showDialog(context);
             },
             child: Icon(Icons.add_a_photo,size:90,color: Colors.white,)),
       ),
     ):
     Container(
         child:
         Column(
           children: [
             SizedBox(height: 30,),
             Container(
               decoration: BoxDecoration(
                   color: Colors.grey.withAlpha(30),
                   border: Border.all(
                     color: Colors.black.withAlpha(80),
                   )
               ),
               child: Image.file(File(imageFile.path),fit:BoxFit.contain,height: 200,width: 200,),
             ),



           ],
         )
     );
     return wid;
   }

   _showDialog(BuildContext context){
     var dlg = AlertDialog(
       title:Text("請選擇方式"),
       actions: [
         TextButton(onPressed: (){
           _getImage(context,ImageSource.camera);
           Navigator.pop(context);
         }, child: Text("拍照")),
         TextButton(onPressed: (){
           _getImage(context,ImageSource.gallery);
           Navigator.pop(context);
         }, child: Text("從手機獲取")),
       ],
     );

     showDialog(
       context: context,
       builder:(context)=>dlg,
     );
   }

  @override
  Widget build(BuildContext context) {
    return  ValueListenableBuilder<XFile?>(
          valueListenable: imageFileNotifier,
          builder: _imageBuilder
    );
  }




}

