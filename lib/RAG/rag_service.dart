import 'package:flutter/widgets.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as gai; // 加上 gai 前綴
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class RagService {
  static Future<String> performSearch(String query) async {
    try {
      // 1. 使用 FirebaseAI 取得模型實例
      // 注意：這裡返回的是 google_generative_ai 的 GenerativeModel
      final model = gai.GenerativeModel(
        model: 'gemini-embedding-001',
        apiKey: dotenv.env['Gemini_API_KEY'] ?? ""
      );

      // 2. 生成 Embedding
      final content = gai.Content.text(query);
      final result = await model.embedContent(content);
      final vector = result.embedding.values;

      print("🧪 [維度測試] 生成的向量維度為: ${vector.length}"); // 看看這裡印出多少

      // 4. 呼叫 Supabase RPC
      final List<dynamic> response = await Supabase.instance.client.rpc(
        'match_diet_docs',
        params: {
          'query_embedding': vector,
          'match_threshold': 0.4,
          'match_count': 3,
        },
      );

      if (response.isEmpty) return "未找到相關參考資料。";
      else{print("✅ [檢索成功] 找到 ${response.length} 筆相關資料");}

      return response.map((item) => item['content']).join('\n\n---\n\n');
    } catch (e,stack) {
      debugPrint("🚨 RAG 執行崩潰：$e");
      debugPrint("🚨 錯誤堆疊：$stack");
      return "搜尋資料庫時發生錯誤: $e";
    }
  }
}