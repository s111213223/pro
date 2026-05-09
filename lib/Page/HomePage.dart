import 'package:flutter/material.dart';
import 'package:project_ai/component/drawer.dart';
import '../component/home_button_bar.dart';

class HomePage extends StatefulWidget {


  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomepageState();
}

class _HomepageState extends State<HomePage> {

  final ValueNotifier<String> _msg = ValueNotifier('');
  Widget _showMsg(BuildContext context,String msg,Widget? child){
    final widget = Text(msg,style: TextStyle(fontSize: 20),
    );
     return widget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        leading: Builder(
          builder: (context)=> IconButton(
                onPressed: (){
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(
                  Icons.sort,
                  color: Colors.black,
                )
            ),
        ),
        title: Text("AI應用"),
      ),
      drawer: Mydrawer(),
      body:
        ValueListenableBuilder<String>(
            valueListenable: _msg,
            builder: _showMsg,
        ),
      bottomNavigationBar: homebuttonbar(),
      );
  }
}
