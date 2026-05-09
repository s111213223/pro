import 'package:flutter/material.dart';
import 'package:project_ai/component/drawer.dart';
import 'package:project_ai/component/home_button_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_ai/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class userdata extends StatefulWidget {
  userdata({super.key});

  @override
  State<userdata> createState() => _userdataState();
}

class _userdataState extends State<userdata> {
  @override
  void initState() {
    super.initState(); // 必須呼叫
    _getTodayTotalCalories();
    _getTodayCarbs();
    _getTodaySugar();
  }

  Future<double> _getTodayTotalCalories() async {
    // 1. 取得今天凌晨的時間 (本地時間轉為 ISO 字串)
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
    final currentUser = Supabase.instance.client.auth.currentUser;

    try {
      // 2. 查詢 Supabase：建立時間大於等於今天凌晨的資料

      if (currentUser == null) {
        return 0.0;
      }
      final List<dynamic> response = await Supabase.instance.client
          .from('diet_log')
          .select('calories')
          .eq('user_id', currentUser.id)
          .gte('created_at', todayStart);

      // 3. 加總熱量 (型別安全處理)
      double total = response.fold(0.0, (sum, item) {
        return sum + (item['calories'] as num? ?? 0).toDouble();
      });

      return total;
    } catch (e) {
      print("今日熱量抓取錯誤: $e");
      return 0.0;
    }
  }

  Future<double> gettodaycalories() async {
    return await _getTodayTotalCalories();
  }

  // 單獨抓取今天的碳水化合物總和
  Future<double> _getTodayCarbs() async {
    final now = DateTime.now();
    // 2. 建立「本地」今天凌晨 00:00 的物件
    // 例如：2026-04-02 00:00:00.000 (Local)
    final localTodayStart = DateTime(now.year, now.month, now.day);

    // 3. 重要：將本地 00:00 轉為 UTC 時間送去查詢
    // 這會變成 2026-04-01 16:00:00.000Z (UTC)
    final queryStart = localTodayStart.toUtc().toIso8601String();

    try {
      final List<dynamic> response = await Supabase.instance.client
          .from('diet_log')
          .select('carbs') // 只抓取碳水欄位
          .gte('created_at', localTodayStart);

      double total = response.fold(0.0, (sum, item) {
        return sum + (item['carbs'] as num? ?? 0).toDouble();
      });
      return total;
    } catch (e) {
      print("今日碳水抓取錯誤: $e");
      return 0.0;
    }
  }

// 單獨抓取今天的糖分總和
  Future<double> _getTodaySugar() async {
    final now = DateTime.now();
    // 2. 建立「本地」今天凌晨 00:00 的物件
    // 例如：2026-04-02 00:00:00.000 (Local)
    final localTodayStart = DateTime(now.year, now.month, now.day);

    try {
      final List<dynamic> response = await Supabase.instance.client
          .from('diet_log')
          .select('sugar') // 只抓取糖分欄位
          .gte('created_at', localTodayStart);

      double total = response.fold(0.0, (sum, item) {
        return sum + (item['sugar'] as num? ?? 0).toDouble();
      });
      return total;
    } catch (e) {
      print("今日糖分抓取錯誤: $e");
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text(
          "總覽",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.sort)),
        ),
        automaticallyImplyLeading: false,
      ),
      drawer: Mydrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 40, right: 30, left: 30),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue[200],
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, spreadRadius: 2, blurRadius: 2)
                  ]),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [],
                        ),
                        // Text("",
                        //   style: TextStyle(color:Colors.white),
                        // ),
                        Text(
                          "今日攝取狀況",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            FutureBuilder<double>(
                              future: gettodaycalories(), // 呼叫你的非同步方法
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  // 資料載入中
                                  return CircularProgressIndicator(
                                      strokeWidth: 2);
                                } else if (snapshot.hasError) {
                                  // 發生錯誤
                                  return Text("Error",
                                      style: TextStyle(color: Colors.red));
                                } else {
                                  // 成功取得資料，顯示總和（若無資料則顯示 0）
                                  double total = snapshot.data ?? 0.0;
                                  return Text(
                                    total.toStringAsFixed(0), // 去掉小數點
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                              },
                            ),
                            // 這裡可以加上單位
                            Text(" kcal",
                                style: TextStyle(
                                    fontSize: 30, color: Colors.white70)),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Flex(
                          direction: Axis.horizontal,
                          children: [
                            // --- 碳水化合物區塊 ---
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black.withAlpha(30))),
                                child: Column(
                                  children: [
                                    Text("碳水化合物",
                                        style: TextStyle(fontSize: 20)),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // 單獨為碳水建立 FutureBuilder
                                        FutureBuilder<double>(
                                          future: _getTodayCarbs(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white));
                                            }
                                            double value = snapshot.data ?? 0.0;
                                            return Text(
                                              value.toStringAsFixed(1),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            );
                                          },
                                        ),
                                        SizedBox(width: 5),
                                        Text("(g)",
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            // --- 糖分區塊 ---
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black.withAlpha(30))),
                                child: Column(
                                  children: [
                                    Text("糖", style: TextStyle(fontSize: 20)),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // 單獨為糖分建立 FutureBuilder
                                        FutureBuilder<double>(
                                          future: _getTodaySugar(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white));
                                            }
                                            double value = snapshot.data ?? 0.0;
                                            return Text(
                                              value.toStringAsFixed(1),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            );
                                          },
                                        ),
                                        SizedBox(width: 5),
                                        Text("(g)",
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //   children: [
                        //     Container(
                        //       padding: EdgeInsets.all(5),
                        //       decoration: BoxDecoration(
                        //         border: Border.all(
                        //           color: Colors.black.withAlpha(30)
                        //         )
                        //       ),
                        //       child:
                        //       Column(
                        //         children: [
                        //           Text("碳水化合物",style: TextStyle(fontSize: 20),),
                        //           SizedBox(height: 5,),
                        //           Row(
                        //             children: [
                        //               Text("100",style: TextStyle(color: Colors.white,fontSize: 20),),
                        //               SizedBox(width: 5,),
                        //               Text("(g)",style: TextStyle(color:Colors.black),)
                        //             ],
                        //           )
                        //         ],
                        //       ),
                        //     ),
                        //     SizedBox(width: 10,),
                        //     Container(
                        //       width: 100,
                        //       padding: EdgeInsets.all(5),
                        //       decoration: BoxDecoration(
                        //           border: Border.all(
                        //               color: Colors.black.withAlpha(30)
                        //           )
                        //       ),
                        //       child:
                        //       Column(
                        //         children: [
                        //           Text("糖",style: TextStyle(fontSize: 20),),
                        //           SizedBox(height: 5,),
                        //           Row(
                        //             children: [
                        //               Text("150",style: TextStyle(color: Colors.white,fontSize: 20),),
                        //               SizedBox(width: 5,),
                        //               Text("(g)",style: TextStyle(color: Colors.black),)
                        //             ],
                        //           )
                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // Row(
                        //   children: [
                        //     Text("1190",
                        //       style: TextStyle(
                        //         fontSize: 30,
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.bold
                        //       ),
                        //     ),
                        //     SizedBox(width: 5,),
                        //     Text("kcal",
                        //       style: TextStyle(
                        //           color: Colors.white,
                        //           fontSize: 20,
                        //           // fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //     SizedBox(width: 5,),
                        //     Text("/-kcal",
                        //       style:TextStyle(
                        //         fontSize: 17
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 10,),
                        //進度條
                        // LinearProgressIndicator(
                        //   value: 0.5,
                        //   backgroundColor: Colors.white,
                        //   valueColor: AlwaysStoppedAnimation(Colors.black),
                        // ),
                        SizedBox(
                          height: 20,
                        ),

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Container(
                        //       padding: EdgeInsets.symmetric(vertical: 5,horizontal: 40),
                        //       decoration: BoxDecoration(
                        //         color: Colors.blue[200],
                        //         borderRadius: BorderRadius.circular(5),
                        //         border: Border.all(
                        //           color: Colors.black12.withAlpha(9)
                        //         ),
                        //         // boxShadow: [
                        //         //   BoxShadow(
                        //         //     color: Colors.black12
                        //         //   )
                        //         // ]
                        //       ),
                        //       child:Column(
                        //         children: [
                        //           Text("剩餘熱量"),
                        //           SizedBox(height: 5,),
                        //           Text("0 kcal"),
                        //         ],
                        //       ),
                        //     ),
                        //     SizedBox(width: 15,),
                        //     Container(
                        //       padding: EdgeInsets.symmetric(vertical: 5,horizontal: 45),
                        //       decoration: BoxDecoration(
                        //         color: Colors.blue[200],
                        //         borderRadius: BorderRadius.circular(5),
                        //         border: Border.all(
                        //           color: Colors.black12.withAlpha(9)
                        //         )
                        //       ),
                        //       child:Column(
                        //         crossAxisAlignment: CrossAxisAlignment.center,
                        //         children: [
                        //           Text("達成率"),
                        //           SizedBox(height: 2,),
                        //           Text("50%"),
                        //         ],
                        //       ),
                        //     )
                        //   ],
                        // )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, right: 30, left: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, spreadRadius: 2, blurRadius: 2)
                ],
              ),
              child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                future: _getSevenDaysGroupedData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 300,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final groupedData = snapshot.data ?? {};
                  final double averageKcal =
                      _calculateAverageCalories(groupedData);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("WEEKLY TREND",
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "近七天熱量趨勢",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            // 平均熱量顯示標籤
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black12,
                                        spreadRadius: 2,
                                        blurRadius: 2)
                                  ]),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  "平均 ${averageKcal.round()} kcal",
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        // 長條圖
                        SizedBox(
                          height: 250,
                          child: BarChart(
                            BarChartData(
                              maxY: 2500,
                              barGroups:
                                  _buildRecentSevenDaysGroups(groupedData),
                              alignment: BarChartAlignment.spaceAround,
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      DateTime date = DateTime.now().subtract(
                                          Duration(days: 6 - value.toInt()));
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          "${date.month}/${date.day}",
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 35,
                                    getTitlesWidget: (value, meta) => Text(
                                        "${value.toInt()}",
                                        style: const TextStyle(fontSize: 10)),
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (_) => Colors.blueAccent,
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      "總攝取\n${rod.toY.round()} Kcal",
                                      const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.only(top: 20, right: 30, left: 30, bottom: 90),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 2, spreadRadius: 2)
                  ]),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              "assets/Icons/ai-technology.png",
                              width: 40,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              children: [
                                Text(
                                  "SMART COACH",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  "AI營養師建議",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                          children: [
                            FutureBuilder(
                                future: _getTodayCarbs(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white));
                                  }
                                  double value = snapshot.data ?? 0.0;
                                  if (value > 150) {
                                    return Text(
                                      "今日攝取碳水總量有點過高，建議攝取低醣類的食物"
                                      "如：燕麥、糙米等",
                                      style: TextStyle(color: Colors.grey),
                                    );
                                  }
                                  return Text(
                                    "目前尚無足夠數據進行分析。請開始紀錄您的飲食，"
                                    "AI營養師將會根據你的攝取狀況提供個人化建議。",
                                    style: TextStyle(color: Colors.grey),
                                  );
                                })
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: homebuttonbar(),
    );
  }
}

double _calculateAverageCalories(
    Map<String, List<Map<String, dynamic>>> groupedData) {
  double totalSum = 0;
  int recordedDays = 0; // 用來記錄「有數據的天數」
  DateTime now = DateTime.now();

  for (int i = 0; i < 7; i++) {
    DateTime date = now.subtract(Duration(days: i));
    String dateStr =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    List<Map<String, dynamic>> dayMeals = groupedData[dateStr] ?? [];

    // 如果這天有紀錄
    if (dayMeals.isNotEmpty) {
      recordedDays++; // 分母加 1
      double dayTotal = dayMeals.fold(0.0, (sum, item) {
        return sum + (item['calories'] as num? ?? 0).toDouble();
      });
      totalSum += dayTotal;
    }
  }

  // 防止分母為 0 (如果這七天完全沒資料)
  if (recordedDays == 0) return 0.0;

  // 計算平均：總量 / 有紀錄的天數
  return totalSum / recordedDays;
}

List<BarChartGroupData> _buildRecentSevenDaysGroups(
    Map<String, List<Map<String, dynamic>>> groupedData) {
  List<BarChartGroupData> groups = [];
  DateTime now = DateTime.now();

  // 產生過去 7 天的數據 (從 6 天前到今天)
  for (int i = 6; i >= 0; i--) {
    DateTime date = now.subtract(Duration(days: i));
    // 格式化日期 key (例如: 2026-04-01)
    String dateStr =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    // 從 Map 中抓取該日的資料，若無則給空陣列
    List<Map<String, dynamic>> dayMeals = groupedData[dateStr] ?? [];

    // 加總該日的熱量 (處理型別保護)
    double totalKcal = dayMeals.fold(0.0, (sum, item) {
      return sum + (item['calories'] as num? ?? 0).toDouble();
    });

    int index = 6 - i; // X 軸索引 (0~6)

    groups.add(
      BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: totalKcal,
            color: totalKcal > 2000 ? Colors.orange[400] : Colors.blue[400],
            width: 30,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 2500, // 對應你設定的 maxY
              color: Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }
  return groups;
}

Future<Map<String, List<Map<String, dynamic>>>>
    _getSevenDaysGroupedData() async {
  final sevenDaysAgo =
      DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

  // 從 Supabase 抓取近七天資料
  final List<dynamic> response = await Supabase.instance.client
      .from('diet_log')
      .select()
      .gte('created_at', sevenDaysAgo);

  Map<String, List<Map<String, dynamic>>> grouped = {};

  for (var log in response) {
    // 轉為在地時間避免時區錯誤
    DateTime localTime = DateTime.parse(log['created_at'].toString()).toLocal();
    String dateKey =
        "${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')}";

    if (grouped[dateKey] == null) {
      grouped[dateKey] = [];
    }
    grouped[dateKey]!.add(log as Map<String, dynamic>);
  }

  return grouped;
}
