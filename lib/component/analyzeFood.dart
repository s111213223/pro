import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

import 'food_prompt_constants.dart';

String get _Apikey => dotenv.env['Gemini_API_KEY'] ?? "error";

//建置模型
final model = GenerativeModel(
    model: "gemini-2.5-flash",
    apiKey: _Apikey);

class analyzefoodphoto{

  String result ="";

  Future<String>analyzefood(XFile photo) async{
    final imageBytes = await photo.readAsBytes();
    final prompt = TextPart(kPhotoFoodPromptForGemini);
    final imagePart = DataPart('image/jpeg', imageBytes);
    try {
      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);
      result = response.text.toString();
      print("分析結果: ${response.text}");

    } catch(e) {
      print("發生錯誤: $e");
    }

    return result;
  }


  Future<String>analyzefoodbytext(String text) async{
    final  usertext = TextPart(text);
    final prompt = TextPart(
        "你是一位營養飲食分析專家，根據使用者所輸入的【食物名稱】與【份量】，推算各食材熱量與份量，"
        "比如:品名咖哩飯，紅蘿蔔|100|400、雞肉|150|400，：結果中不得包含使用者輸入的原始品名（例如：輸入咖哩飯，清單中不可出現「咖哩飯」這一行。"
        "$kFoodPipeFormatRule");

    try {
      final response = await model.generateContent([
        Content.multi([prompt, usertext])
      ]);
      result = response.text.toString();
      print("分析結果: ${response.text}");

    } catch (e) {
      print("發生錯誤: $e");
    }

    return result;
  }

}

