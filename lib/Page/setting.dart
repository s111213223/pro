import 'package:flutter/material.dart';
import 'package:project_ai/component/drawer.dart';
import 'package:project_ai/auth/auth_service.dart';


class setting extends StatefulWidget {
  const setting({super.key});

  @override
  State<setting> createState() => _settingState();
}

class _settingState extends State<setting> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectValue = "男";
  String? _selectValue_another = "久坐(無運動)";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // double malebmr(Map data){
  //   return (10*data['weight']+6.25*data['height']-5*data['age']+5);
  // }
  //
  // double femalebmr(Map data){
  //   return (10*data['weight']+6.25*data['height']-5*data['age']-161);
  // }
  String? _bmr="";
  int _calculateBmr(Map data){
    int par = 5;
    if(data['gender']=='女'){
       par =  -161;
    }
    if(data['activity_level']=='久坐(無運動)'){
      print(1);
      return  ((10*data['weight']+6.25*data['height']-5*data['age']+par)*1.2).toInt();
    }
    if(data['activity_level']=='輕度活動(1-3天/週)'){
      print(2);
      return ((10*data['weight']+6.25*data['height']-5*data['age']+par)*1.375).toInt();
    }
    if(data['activity_level']=='中度活動(3-5天/週)'){
      return ((10*data['weight']+6.25*data['height']-5*data['age']+par)*1.55).toInt();
    }
    if(data['activity_level']=='高度活動(6-7天/週)'){
      return  ((10*data['weight']+6.25*data['height']-5*data['age']+par)*1.72).toInt();
    }

    return 0;

  }
  final SupabaseAuth _supabaseService = SupabaseAuth();



  Future<void> _loadData() async {
    final data = await _supabaseService.fetchUserprofile();
    if(data==null) return;


    if (mounted ) {
      setState(() {
        _bmr = _calculateBmr(data).toString();
        _nameController.text = data['nickname'];
        _selectValue = data['gender'];
        _weightController.text= data['weight'].toString();
        _heightController.text = data['height'].toString();
        _ageController.text= data['age'].toString();
        _selectValue_another=data['activity_level'].toString();
      });
    }
  }

  @override
  void initState(){
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text("個人檔案",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: (){
            showDialog(context: context, builder: (BuildContext context){
              return AlertDialog(
                title: Text("是否要登出"),
                actions: [
                  TextButton(onPressed: (){Navigator.pop(context);}, child: Text("取消",style: TextStyle(color: Colors.black),)),
                  TextButton(onPressed: ()async{
                    await _supabaseService.SignOut();
                    Navigator.pushNamedAndRemoveUntil(context,'/auth',(route)=>false);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("登出成功")));
                  }, child: Text("登出",style: TextStyle(color: Colors.red))),
                ],
              );
            }
            );
          }, icon: Icon(Icons.logout))
        ],
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.sort),
          ),
        ),
      ),
      drawer: Mydrawer(),
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
                contentPadding: EdgeInsetsGeometry.directional(start: 5)
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
              onPressed: ()async{
                if (_formKey.currentState!.validate()) {
                  Map<String,dynamic> _currentMessage={
                    "gender":_selectValue.toString(),
                    "age":int.parse(_ageController.text),
                    "height":double.parse(_heightController.text),
                    "weight":double.parse(_weightController.text),
                    "activity_level":_selectValue_another
                  };
                  if(_currentMessage!=null){
                     setState(() {
                      _bmr=_calculateBmr(_currentMessage).toString();
                     });
                  }

                  await _supabaseService.saveProfile(_nameController.text, _selectValue.toString(),_ageController.text ,_heightController.text, _weightController.text, _selectValue_another.toString());
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text("計算與儲存中...")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("資料格式錯誤，請確認")));
                }
              },
              child: Text("計算並儲存"),
            )
          ),
          SizedBox(height: 15,),
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
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.fromLTRB(20, 5, 20, 10),
            padding: EdgeInsets.all(20),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("每日熱量建議",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,
                        fontSize: 15),
                    ),
                  ],
                ),
                Divider(
                  height: 30,
                  color: Colors.black,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("每日消耗(TDEE):",style: TextStyle(color: Colors.black),),
                    Row(
                      children: [
                        Text(_bmr.toString(),style: TextStyle(color: Colors.black,fontSize: 20),),
                        SizedBox(width:5,),
                        Text("kcal")
                      ],
                    )

                  ],
                ),
                // SizedBox(height: 10,),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text("建議攝取:",style: TextStyle(color: Colors.black,fontSize: 15),),
                //     Row(
                //       children: [
                //         Text("2151",style: TextStyle(color: Colors.black,fontSize: 25),),
                //         SizedBox(width: 5,),
                //         Text("kcal")
                //       ],
                //     )
                //   ],
                // )
              ],
            ),
          )
        ],
        ),
      )
      )
    );
  }
}
