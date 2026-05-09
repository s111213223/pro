/// 熱量為 Kcal、份量為克；輸出僅「品名|份量|熱量」每行一筆，勿寫單位字尾。
const String kFoodPipeFormatRule =
    '請嚴格遵守以下格式，不要有任何解釋文字，熱量單位是Kcal、份量單位克。單位不需要標記上去：品名|份量|熱量，範例：炸雞|1|400';

/// 照片分析 Gemini 提示詞（與原先 `analyzeFood.dart` 內文一致）。
const String kPhotoFoodPromptForGemini =
    '分析照片中的食物，每一食材一行。$kFoodPipeFormatRule';
