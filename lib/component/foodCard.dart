import 'package:flutter/material.dart';
import 'package:project_ai/component/food_item.dart';

class foodcard extends StatefulWidget {

  final int index;
  final FoodItem item;
  final Function(FoodItem) onChanged;
  final VoidCallback onDelete;

  const foodcard({super.key,
    required this.index,
    required this.item,
    required this.onChanged,
    required this.onDelete}
  );

  @override
  State<foodcard> createState() => _foodcardState();
}

class _foodcardState extends State<foodcard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal:30 ,vertical: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 2,
            blurRadius: 2
          )
        ]
      ),
      child:Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: TextField(
                controller: TextEditingController(text: widget.item.name),
                 // ..selection = TextSelection.collapsed(offset: item.name.length),
                style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),
                decoration: InputDecoration(border: InputBorder.none,isDense: true),
                onChanged: (val){
                  widget.item.name =  val;
                  widget.onChanged(widget.item);
                },
                )
              ),
            ],
          ),
          Divider(height: 20,),
          Row(
            children: [
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("份量(克)"),
                      TextField(
                        controller: TextEditingController(text: widget.item.weight.toString()),
                        decoration: InputDecoration(border: InputBorder.none,isDense: true),
                        onChanged: (val){
                          widget.item.weight = int.tryParse(val)?? 0;
                          widget.onChanged(widget.item);
                          setState(() {});
                        },
                      )
                    ],
                  )
              ),
              Expanded(child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("熱量(Kcal)"),
                        SizedBox(
                          width: 80,
                          child: Text(
                              widget.item.allcalories.toString(),
                              textAlign: TextAlign.end
                              ,style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold)
                          ),
                          // child: TextField(
                          //   controller: TextEditingController(text: item.calories.toString()),
                          //   textAlign: TextAlign.end,
                          //   keyboardType: TextInputType.number,
                          //   style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),
                          //   decoration: InputDecoration(border: InputBorder.none,isDense: true),
                          //   onChanged: (val){
                          //     item.calories = int.tryParse(val)?? 0;
                          //     onChanged(item);
                          //   },
                          // ),
                        ),
                      ],
                    ),
                    IconButton(onPressed: (){widget.onDelete();}, icon: Icon(Icons.delete))
                  ],
                )

              )
            ],
          )
        ],
      ) ,
    );
  }
}
