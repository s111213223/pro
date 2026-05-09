import 'package:flutter/material.dart';

class handSize extends StatefulWidget {
  const handSize({super.key});

  @override
  State<handSize> createState() => _handSizeState();
}

class _handSizeState extends State<handSize> {
  bool _showDialog = true;

  final _palmWidthController = TextEditingController();
  final _palmLengthController = TextEditingController();
  final _palmThicknessController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInfoDialog();
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                'assets/graph/hand.png',
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(35.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('了解', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _palmWidthController.dispose();
    _palmLengthController.dispose();
    _palmThicknessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
          title: Text("設定手掌數值",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 手掌掌心寬度
            Text('手掌掌心寬度 (cm)',
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            SizedBox(height: 8),
            TextFormField(
              controller: _palmWidthController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '例如：8.5',
                suffixText: 'cm',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 20),

            // 手掌掌心長度
            Text('手掌掌心長度 (cm)',
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            SizedBox(height: 8),
            TextFormField(
              controller: _palmLengthController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '例如：10.0',
                suffixText: 'cm',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 20),

            // 手掌厚度
            Text('手掌厚度 (cm)',
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            SizedBox(height: 8),
            TextFormField(
              controller: _palmThicknessController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '例如：2.5',
                suffixText: 'cm',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 32),

            // 確認按鈕
            Row(
              children: [
                // 略過按鈕
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.restorablePushReplacementNamed(context, '/userdata');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('略過', style: TextStyle(color: Colors.grey[700])),
                  ),
                ),
                SizedBox(width: 12),
                // 送出按鈕
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final width = double.tryParse(_palmWidthController.text);
                      final length = double.tryParse(_palmLengthController.text);
                      final thickness = double.tryParse(_palmThicknessController.text);

                      if (width == null || length == null || thickness == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('請確認所有欄位皆為正確數字')),
                        );
                        return;
                      } else {
                        Navigator.pushReplacementNamed(context, '/userdata');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('存儲成功')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('送出'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*
  全榖雜糧類: 男生：大約 225~300(g)、女生：大約 150~225(g)
  水果類：大約 400(g)
  乳品類：大約 240~480 (g)
  豆魚肉蛋類:男生：大約１個手掌心～1.2手掌心、女生：大約0.8個手掌心~1個手掌心
  蔬菜類:大約 300~500 (g)
  油脂堅果種子類：男生:大約30(g)、女生:大約22.5(g)
*/