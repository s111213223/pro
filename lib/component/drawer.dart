import 'package:flutter/material.dart';
import 'package:project_ai/Page/HomePage.dart';
import 'package:project_ai/Page/foodLog.dart';
import 'package:project_ai/Page/mood.dart';
import 'package:project_ai/Page/setting.dart';
import 'package:project_ai/Page/userdata.dart';
import 'package:project_ai/Page/AI_chat.dart';
import 'package:project_ai/component/image.dart';
import 'package:project_ai/Page/music.dart';
import 'package:project_ai/auth/auth_service.dart';

class Mydrawer extends StatefulWidget {
  Mydrawer({super.key});

  @override
  State<Mydrawer> createState() => _MydrawerState();
}

class _MydrawerState extends State<Mydrawer> {

  final info =<String>["匿稱","電子郵件"];
  String name = "NTUE";
  String mail = "s111@gmail.com";


  final SupabaseAuth _supabaseService = SupabaseAuth();

  Future<void> _loadData()async{
    print("成功載入");
    final Data = await _supabaseService.fetchUserprofile();
    final Email = _supabaseService.supabase.auth.currentUser?.email;
    if(mounted){
      setState(() {
        if(Data!=null && Email!=null){
          name = Data['nickname'];
          mail = Email;
        }
      });
    }
  }

  @override
  void initState(){
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
          child: ListView(
            children: [
              // Padding(padding: EdgeInsets.only(top: 0)),
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage("https://plus.unsplash.com/premium_photo-1763304299348-fa91c6dc25ef?q=80&w=1332&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
                      fit: BoxFit.cover),
                ),
                  accountName: Padding(
                        padding: EdgeInsets.fromLTRB(0,5,0,0),
                        child: Text(info[0]+"："+name,
                         style: TextStyle(
                      color: Colors.white,
                     fontWeight: FontWeight.bold,
                     fontSize: 13,
                    ),
                    ),
                  ),
                  accountEmail: Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Text(info[1]+"："+mail,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  currentAccountPicture:
                      CircleAvatar(
                        radius: 10,
                        child: Icon(Icons.person)
                        //child: Image.asset("assets/ik.png"),
                  ),
                ),
              // ListView(
              //   children: [
                    ListTile(
                      title: Text("AI對話",style: TextStyle(color: Colors.black),),
                      leading: Container(
                        child: Icon(Icons.messenger_rounded),
                        padding: EdgeInsets.symmetric(vertical: 8,horizontal: 5),
                      ),
                      onTap: (){
                        Navigator.pop(context); //關閉Drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen()));
                      },
                    ),
                    ListTile(
                      title: Text("AI辨識",style: TextStyle(color: Colors.black),),
                      leading: Container(
                        child: Icon( Icons.camera_alt),
                        padding: EdgeInsets.symmetric(vertical: 8,horizontal: 5),
                      ),
                      onTap: (){
                        Navigator.pop(context);//關閉Drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>image()));
                      },
                    ),
                    ListTile(
                      title: Text("總攬",style: TextStyle(color: Colors.black),),
                      leading: Container(
                        child:  Icon(Icons.data_thresholding),
                        padding: EdgeInsets.symmetric(vertical: 8,horizontal: 5),
                      ),
                      onTap: (){
                        Navigator.pop(context);//關閉Drawer
                        Navigator.push(context, MaterialPageRoute(builder: (context) => userdata()));
                      },
                    ),
                    ListTile(
                        title: Text("療癒",style: TextStyle(color: Colors.black),),
                        leading: Container(
                          child: Icon(Icons.music_note_rounded),
                          padding: EdgeInsets.symmetric(vertical: 8,horizontal: 5),
                        ),
                        onTap: (){
                          Navigator.pop(context);//關閉Drawer
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>showMusic()));
                        }
                    ),
                    ListTile(
                        title: Text("飲食日記",style: TextStyle(color: Colors.black),),
                        leading: Container(
                          child: Icon(Icons.book),
                          padding: EdgeInsets.symmetric(vertical: 8,horizontal: 5),
                        ),
                        onTap: (){
                          Navigator.pop(context);//關閉Drawer
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>foodlog()));
                        }
                    ),
                    Divider(
                      indent: 15,
                      endIndent: 15,
                      color: Colors.black,
                    ),
                    ListTile(
                        title: Text("設定",style: TextStyle(color: Colors.black),),
                        leading: Container(
                          child: Icon(Icons.person),
                          padding: EdgeInsets.symmetric(vertical: 8,horizontal: 5),
                        ),
                        onTap: (){
                          Navigator.pop(context);//關閉Drawer
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>setting()));
                        }
                    ),
                ]
              ),
          );
  }
}
