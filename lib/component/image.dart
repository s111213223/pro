import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_ai/Page/Inputphoto.dart';
import 'package:project_ai/component/drawer.dart';
import 'package:project_ai/component/home_button_bar.dart';
import 'package:project_ai/Page/InputMeal.dart';




class image extends StatelessWidget {
   //image({super.key});

  final ValueNotifier<XFile?>_imageFile = ValueNotifier(null);
  final ImagePicker _imagePicker = ImagePicker(); //建立ImagePicker
  final ValueNotifier<int> _currentPage = ValueNotifier(0);//當前是哪頁

  //取得照片
  // Future<void>_getImage(ImageSource imageSource) async{
  //   XFile? imgfile = await _imagePicker.pickImage(source: imageSource);
  //   _imageFile.value = imgfile;
  // }

  //放出照片
  Widget _imageBuilder(BuildContext context,int _currentPage, Widget? child){
    return inputphoto(imageFileNotifier: _imageFile);
  }

  // Widget _buildImagePage(BuildContext context, int _currentPage, Widget? child,XFile? imagefile ){
  //   return _imageBuilder(context,  imagefile, child);
  // }

  Widget _buildTextInput(BuildContext context, int _currentPage, Widget? child){
    return Inputmeal();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: false,
        title: Text("AI辨識",
        style: TextStyle(fontWeight: FontWeight.bold),),
        automaticallyImplyLeading: false,
        leading: Builder(builder:
            (context) => IconButton(
              onPressed:(){Scaffold.of(context).openDrawer();}
              ,icon: Icon(Icons.sort),
            ),
        ),
        backgroundColor: Colors.blue[400],
      ),
      drawer: Mydrawer(),
      body:
          SingleChildScrollView(
            child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  child: Column(
                    children: [
                      SizedBox(height: 60,),
                      Text("紀錄你的每一餐",
                        style: TextStyle(color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                      Padding(padding: EdgeInsetsGeometry.directional(top: 15)),
                      Text("拍照上傳或輸入文字，AI為你自動計算熱量",
                        style: TextStyle(color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                      Padding(padding: EdgeInsetsGeometry.directional(top: 10)),
                      //以上不動


                      //按鈕區
                      Container(
                        padding: EdgeInsets.only(top: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(onPressed:(){
                              _currentPage.value = 0;

                            },
                              style:
                              ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black
                              ),
                              child: Row(
                                children: [Icon(Icons.camera_alt),
                                  Text(" 拍照 ",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 15
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width:30,),
                            ElevatedButton(onPressed:(){
                              _currentPage.value = 1;
                              _imageFile.value = null;
                            },
                              style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal:20),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black
                              ),
                              child:
                              Row(
                                children: [
                                  Icon(Icons.text_fields_rounded),
                                  Text("文字輸入",
                                    style: TextStyle(color: Colors.grey[600],
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                Container(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _currentPage,
                    builder: (context,pageIndex,child){
                      if(pageIndex==0) {
                        return  _imageBuilder(context, pageIndex, child);
                          // ValueListenableBuilder<XFile?>(
                          //     valueListenable: _imageFile,
                          //     builder: _imageBuilder
                          // );
                      }
                      if(pageIndex==1){
                        return _buildTextInput(context, pageIndex, child);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                )
              ],
            ),
          )
    );
  }
}
