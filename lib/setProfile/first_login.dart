import 'package:flutter/material.dart';
import 'package:project_ai/auth/auth_service.dart';



class firstlogin extends StatefulWidget {
  const firstlogin({super.key});

  @override
  State<firstlogin> createState() => _firstloginState();
}

class _firstloginState extends State<firstlogin> {

  String? _selectValue = null;
  String? _selectValue_another = null;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final SupabaseAuth _supabaseService = SupabaseAuth();

  @override
  void dispose(){
    _nameController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.blue[400],
          title: Text("初次登入",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(onPressed: (){
              Navigator.pushReplacementNamed(context, '/auth');
            },icon:Icon(Icons.arrow_back)),
        ),
        body: SingleChildScrollView(
            child:
            Form(
              key: _formKey,
              child:
              Column(
                children: [
                  SizedBox(height: 20,),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 20),
                        Text("暱稱",
                          style: TextStyle(color: Colors.black, fontSize: 18
                          ),
                        ),
                      ]
                  ),
                  SizedBox(height: 10,),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 2,
                              blurRadius: 2
                          ),
                        ]
                    ),
                    margin: EdgeInsets.fromLTRB(20, 2, 20, 10),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: " 輸入暱稱",
                        border: InputBorder.none,
                      ),
                      validator: (value){
                        if(value==null||value.isEmpty){
                          return "請輸入暱稱";
                        }
                        return null;
                      },
                    ) ,
                  ),
                  SizedBox(height: 10,),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 2, 20, 10),
                    child:
                    Flex(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                            flex: 1,
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("性別",style: TextStyle(color: Colors.black,
                                    fontSize: 18),),
                                SizedBox(height: 10,),
                                Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black12,
                                              spreadRadius: 2,
                                              blurRadius: 2
                                          )
                                        ]
                                    ),
                                    child:
                                    DropdownButtonHideUnderline(child:
                                    DropdownButton<String>(
                                      padding: EdgeInsets.only(left: 5),
                                      isExpanded: true,
                                      hint: Row(
                                        children: [
                                          SizedBox(width: 5,),
                                          Text(" 選擇性別"),
                                        ],
                                      ),
                                      value: _selectValue,
                                      items: <String>['男', '女'].map((String item) {
                                        return DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(item),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectValue = newValue;
                                        });
                                      },
                                    )
                                    )
                                )
                              ],
                            )
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                            flex: 1,
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("年齡",style: TextStyle(color: Colors.black,fontSize: 18),),
                                SizedBox(height: 10,),
                                Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black12,
                                              spreadRadius: 2,
                                              blurRadius: 2
                                          )
                                        ]
                                    ),
                                    child:
                                    TextFormField(
                                      controller: _ageController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: " 輸入年齡",
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 5,),
                                      ),
                                      validator: (value){
                                        if(value==null || value.isEmpty){
                                          return "請輸入年齡";
                                        }
                                        return null;
                                      },
                                    )
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 2, 20, 10),
                    child:
                    Flex(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                            flex: 1,
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("身高(cm)",style: TextStyle(color: Colors.black,
                                    fontSize: 18),),
                                SizedBox(height: 10,),
                                Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black12,
                                              spreadRadius: 2,
                                              blurRadius: 2
                                          )
                                        ]
                                    ),
                                    child:
                                    TextFormField(
                                      controller: _heightController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 5,),
                                          hintText: " 輸入身高(cm)",
                                          border: InputBorder.none
                                      ),
                                      validator: (value){
                                        if(value==null||value.isEmpty){
                                          return "請輸入身高";
                                        }
                                        return null;
                                      },
                                    )
                                )
                              ],
                            )
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                            flex: 1,
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("體重(kg)",style: TextStyle(color: Colors.black,fontSize: 18),),
                                SizedBox(height: 10,),
                                Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black12,
                                              spreadRadius: 2,
                                              blurRadius: 2
                                          )
                                        ]
                                    ),
                                    child:
                                    TextFormField(
                                      controller: _weightController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          hintText: " 輸入體重(kg)",
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 5,)
                                      ),
                                      validator: (value){
                                        if(value==null||value.isEmpty){
                                          return "請輸入體重";
                                        }
                                        return null;
                                      },
                                    )
                                ),
                              ],
                            )
                        ),
                        SizedBox(height: 10,),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 5, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("活動量",style: TextStyle(color: Colors.black,fontSize: 20),),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    spreadRadius: 2,
                                    blurRadius: 2
                                )
                              ],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            width: double.infinity,
                            child:
                            DropdownButtonHideUnderline(child:
                            DropdownButton<String>(
                              padding: EdgeInsets.only(left: 5),
                              isExpanded: true,
                              hint: Row(
                                children: [
                                  SizedBox(width: 5,),
                                  Text("選擇活動量")
                                ],
                              ),
                              value: _selectValue_another, //
                              items: <String>['久坐(無運動)', '輕度活動(1-3天/週)','中度活動(3-5天/週)','高度活動(6-7天/週)'].map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectValue_another = newValue;
                                });
                              },
                            )
                            )
                        )
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                      width: double.infinity,
                      child:
                      TextButton(
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.all(10),
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.blue[400],
                            shape: BeveledRectangleBorder(borderRadius:BorderRadius.circular(2))
                        ),
                        onPressed: (){
                          if (_formKey.currentState!.validate()) {

                            if(_selectValue_another!=null && _selectValue!=null){
                              _supabaseService.saveProfile(_nameController.text,_selectValue.toString(),_ageController.text,_heightController.text,_weightController.text,_selectValue_another.toString());
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //     SnackBar(content: Text("資料格式正確，儲存中...")));
                              Navigator.pushReplacementNamed(context, '/handsize');
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("資料格式錯誤，請確認")));
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("資料格式錯誤，請確認")));
                          }
                        },
                        child: Text("儲存"),
                      )
                  ),
                ],
              ),
            )
        )
    );
  }
}
