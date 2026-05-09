import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

import 'food_prompt_constants.dart';

String get _Apikey => dotenv.env['Gemini_API_KEY'] ?? "error";

//建置模型
final model = GenerativeModel(
    model: "gemini-2.5-flash",
    apiKey: _Apikey);

String result = "";

class analyzefoodphoto {

  Future<String> analyzefood(XFile photo) async {
    final imageBytes = await photo.readAsBytes();
    final prompt = TextPart(kPhotoFoodPromptForGemini);
    final imagePart = DataPart('image/jpeg', imageBytes);
    try {
      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      result = response.text.toString();
      print("分析結果: ${response.text}");


    } catch (e) {
      print("發生錯誤: $e");

    }

    return result;
  }

}

