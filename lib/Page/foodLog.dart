import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_ai/component/drawer.dart';

class foodlog extends StatefulWidget {
  const foodlog({super.key});

  @override
  State<foodlog> createState() => _foodlogState();
}

class _foodlogState extends State<foodlog> {
  late Future<List<Map<String, dynamic>>> _getLogsFuture;

  @override
  void initState() {
    super.initState();
    // 1. 先取得目前登入的使用者
    final currentUser = Supabase.instance.client.auth.currentUser;

    // 2. 確保使用者已登入 (避免 currentUser 為 null 導致閃退)
    if (currentUser != null) {
      _getLogsFuture = Supabase.instance.client
          .from('diet_log')
          .select()
          .eq('user_id', currentUser.id) // 🌟 關鍵新增：只篩選 user_id 等於自己的資料
          .order('created_at', ascending: false);
    } else {
      // 若未登入的防呆處理 (實務上通常會導回登入頁)
      _getLogsFuture = Future.value([]);
    }
  }

  // --- 關鍵函式：按日期分組並計算總量 ---
  Map<String, List<Map<String, dynamic>>> _groupLogsByDate(List<Map<String, dynamic>> logs) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var log in logs) {
      // 擷取日期部分 YYYY-MM-DD
      String date = log['created_at'].toString().split("T")[0];
      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(log);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("飲食日記", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[400],
      ),
      drawer:  Mydrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getLogsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final allLogs = snapshot.data ?? [];
          if (allLogs.isEmpty) return const Center(child: Text("尚無紀錄"));

          // 1. 執行分組
          final groupedData = _groupLogsByDate(allLogs);
          final List<String> sortedDates = groupedData.keys.toList(); // 日期已由 SQL 排序過

          return ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              String date = sortedDates[index];
              List<Map<String, dynamic>> dayMeals = groupedData[date]!;

              // 2. 計算該日總量
              int dayTotalKcal = dayMeals.fold(0, (sum, item) => sum + (item['calories'] as num? ?? 0).toInt());

              return Column(
                children: [
                  // 每一天最上方的大卡片 (今日摘要)
                  _buildDailySummaryCard(dayTotalKcal, date),

                  // 該天底下的所有細項
                  ...dayMeals.map((meal) => _buildLogCard(meal)).toList(),

                  const SizedBox(height: 20), // 每一天之間的間距
                ],
              );
            },
          );
        },
      ),
    );
  }

  // 每一天的藍色摘要卡片
  Widget _buildDailySummaryCard(int total, String date) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue[400]!, Colors.blue[600]!]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const Text("單日總量", style: TextStyle(color: Colors.white, fontSize: 18, ),
              )],
          ),
          Text("$total Kcal", style: const TextStyle(color: Colors.white, fontSize: 24, )),
        ],
      ),
    );
  }

  // 你原本的單筆紀錄卡片組件 (稍微微調下)
  Widget _buildLogCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          // 圖片顯示 (從 image_url 讀取網路圖片)
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey[100],
              child: data['image_url'] != null && data['image_url'].toString().isNotEmpty
                  ? Image.network(
                data['image_url'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
              )
                  : const Icon(Icons.fastfood, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 15),
          // 營養數據與名稱
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name'] ?? "未命名餐點",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("熱量：${data['calories']} Kcal"),
                Text("碳水：${(data['carbs']as num).toInt()}g", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text("蛋白質：${(data['protein']as num).toInt()}g", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text("糖：${(data['sugar']as num).toInt()}g", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                if ((data['fiber'] ?? 0) > 0)
                  Text("纖維 ${(data['fiber']as num).round()}g (淨碳水 ${(data['carbs'] - data['fiber']).toStringAsFixed(1)}g)",
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          // 顯示日期 (擷取 created_at 的前 10 字)
          Text(data['created_at'].toString(),style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

}