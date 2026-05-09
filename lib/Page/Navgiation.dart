import 'package:flutter/material.dart';
import 'package:project_ai/Page/HomePage.dart';
import 'package:project_ai/Page/userdata.dart';
import 'package:project_ai/auth/auth_screen.dart';
import 'package:project_ai/component/home_button_bar.dart';

class Navgiation extends StatelessWidget {
  Navgiation({super.key});

  //儲存列表index
  final ValueNotifier<int> _imageIndex = ValueNotifier(0);
  // 影像位置放在List中，並取名為_images
  final _images = <String>[
    'assets/navbar/photo_1.png',
    'assets/navbar/phtoto_2.png',
    'assets/navbar/photo_3.png'
  ];

  Widget _imageBuilder(BuildContext context, int imageIndex, Widget? child) {
    //取得照片位置
    Image img = Image.asset(_images[imageIndex]);
    return img;
  }

  void _pre() {
    _imageIndex.value = _imageIndex.value == 0 ? 0 : _imageIndex.value - 1;
  }

  void _next() {
    _imageIndex.value =
        _imageIndex.value == 2 ? 2 : ++_imageIndex.value % _images.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 100),
            // 照片瀏覽
            Container(
              child: ValueListenableBuilder(
                  valueListenable: _imageIndex, //監聽對象
                  builder: _imageBuilder),
              margin: EdgeInsets.symmetric(vertical: 10),
            ),
            //按鈕區
            // Container(
            //   child: Row(
            //     children: [
            //       IconButton(
            //           onPressed:()=> _pre(),
            //           icon: Icon(
            //             Icons.arrow_left,
            //             color: Colors.green,
            //           ),
            //         iconSize: 90,
            //       ),
            //       IconButton(
            //           onPressed:()=>_next(),
            //           icon: Icon(
            //             Icons.arrow_right,
            //             color: Colors.green,
            //           ),
            //           iconSize: 90,
            //       ),
            //     ],
            //     mainAxisAlignment: MainAxisAlignment.center,
            //   ),
            // )
            const Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 60),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_imageIndex.value == _images.length - 1) {
                        Navigator.pushReplacementNamed(context, '/auth');
                      } else {
                        _next();
                      }
                    },
                    child: Text(
                      _imageIndex.value == _images.length - 1 ? "進入主頁" : "下一步",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        //背景顏色
                        backgroundColor: Colors.cyan,
                        //圓弧
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
