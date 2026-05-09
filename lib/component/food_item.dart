import 'package:image_picker/image_picker.dart';

class FoodItem {
  String name;
  int weight;       // 使用者調整後的重量
  int calories;        // 總熱量 (資料庫單價 * 重量)
  double carbs;        // 總碳水 (資料庫單價 * 重量)
  double sugar;        // 總糖分 (資料庫單價 * 重量)
  double fiber;        // 總纖維
  double protein;
  double similarity; // 相似度分數
  double caloriesprer100;
  String imagePath;

  FoodItem({
    required this.name,
    required this.weight,
    this.caloriesprer100=0,
    this.calories=0,
    this.protein=0,
    this.carbs = 0,
    this.sugar = 0,
    this.fiber = 0,
    this.similarity = 0,
    this.imagePath='',
  });


  int get allcalories =>((caloriesprer100 * weight)/100).round();

}

List<Map<String,dynamic>>foodhis=[];