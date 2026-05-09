import 'package:flutter/material.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:project_ai/component/drawer.dart';
import 'package:project_ai/component/home_button_bar.dart';
import 'package:project_ai/RAG/rag_service.dart';
import 'package:firebase_ai/firebase_ai.dart' ;


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {


  final nutritionTool = FunctionDeclaration(
        'performSearch', // 函數名稱
        '當使用者詢問關於 PDF 內提供的營養指南、專業建議或特定數據時，呼叫此工具獲取正確資訊。',
        parameters:{
          'User_query': Schema.string(
             description: "要搜尋的關鍵字或短語"
          )
        }
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: const Text(
          "AI營養助手",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.sort),
          ),
        ),
      ),
      drawer: Mydrawer(),
      body: LlmChatView(
        autofocus: false,
        provider: FirebaseProvider(
            model: FirebaseAI.googleAI().generativeModel(
                model: "gemini-2.5-flash",
                tools: [
                  Tool.functionDeclarations([
                    nutritionTool
                  ])
                ],
            systemInstruction: Content.system(
                """"
                你是一位專業個人 AI 營養助手。
                請優先去查詢資料庫，在根據用戶提供的文字與之前對話內容。
                給予建議。
                """
            ),
            ),
          onFunctionCall: (call) async {
              debugPrint("🚀 觸發 Function Call");
              debugPrint("📢 [偵測到 AI 動作] 嘗試呼叫函式: ${call.name}");
              debugPrint("📢 [傳入參數內容] 參數: ${call.args}");

              final query = call.args['User_query'] as String;
              if (query == null || query.isEmpty) return {"result": "請提供搜尋關鍵字"};
              final result = await RagService.performSearch(query);
              return {
                "search_result": result
              };
              return {};
          },
        ),
         welcomeMessage: "你好! 我是你的個人AI營養助手，可以幫你分析食物營養、提供飲食建議。有什麼問題嗎?",
         style: LlmChatViewStyle(
           userMessageStyle: UserMessageStyle(
             decoration: BoxDecoration(
               color: Colors.blue.withAlpha(30),
               boxShadow: [
                 BoxShadow(
                   color: Colors.black12
                 )
               ]
             ),
             textStyle: const TextStyle(
               color: Colors.white,
               fontSize: 16,
               fontWeight: FontWeight.w500,
             ),
           ),
           backgroundColor: Colors.white,
           llmMessageStyle: LlmMessageStyle(
             decoration: BoxDecoration(
                color: Colors.grey.withAlpha(70),
                borderRadius: BorderRadius.circular(20),
               border: Border.all(color: Colors.black)
             ),
             padding: EdgeInsets.all(10)
           ),
           chatInputStyle: ChatInputStyle(
            textStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
             hintText: "詢問關於食物熱量或飲食建議",
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              //border: Border.all(color: Colors.grey.shade300),
            ),
          ),
         ),
        ),
      );
  }
}
