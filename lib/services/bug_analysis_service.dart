import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bug_analysis_result.dart';
import '../core/language_service.dart';

class BugAnalysisService {
  static const String _apiKey = 'AIzaSyA70kboxOvyPN-_xxcB3rd6YodCiXTbWjo';
  static const String _endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=';

  String _getPromptForLanguage(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return """Sen uzman bir entomolog ve herpetologsun. Bu böcek, örümcek, yılan, akrep veya diğer küçük hayvanların fotoğrafını analiz et ve detaylı bilgi ver.

ÇOK ÖNEMLİ: Tüm yanıtlar Türkçe olmalı. Sadece bu tam formatta geçerli bir JSON yanıtı döndür, başka metin ekleme:
{
  "name": "Hayvanın yaygın adı (Türkçe)",
  "species": "Bilimsel adı (Latince kalır)",
  "dangerLevel": "düşük/orta/yüksek",
  "description": "Detaylı fiziksel açıklama (Türkçe)",
  "habitat": "Nerede yaşar (Türkçe)",
  "venomous": "Evet/Hayır ve detaylar (Türkçe)",
  "diseases": "Taşıyabileceği veya neden olabileceği hastalıklar (Türkçe)",
  "safetyTips": "İnsanlar için güvenlik tavsiyeleri (Türkçe)"
}

Hatırla: Tüm metinler Türkçe olmalı, sadece bilimsel isimler Latince kalır.

Odaklan:
- Doğru tanımlama
- Tehlike değerlendirmesi (zehirli, zehirli, agresif)
- Sağlık riskleri ve hastalıklar
- Güvenlik önlemleri
- Habitat ve davranış

Kapsamlı ama öz ol. Türü tanımlayamıyorsan, hayvan türü hakkında genel bilgi ver (Türkçe).""";

      case 'es':
        return """Eres un experto entomólogo y herpetólogo. Analiza esta imagen de un insecto, araña, serpiente, escorpión u otro animal pequeño y proporciona información detallada.

MUY IMPORTANTE: Todas las respuestas deben ser en español. Devuelve SOLO una respuesta JSON válida en este formato exacto, sin texto adicional:
{
  "name": "Nombre común del animal (en español)",
  "species": "Nombre científico (permanece en latín)",
  "dangerLevel": "bajo/medio/alto",
  "description": "Descripción física detallada (en español)",
  "habitat": "Dónde vive (en español)",
  "venomous": "Sí/No y detalles (en español)",
  "diseases": "Enfermedades que puede transmitir o causar (en español)",
  "safetyTips": "Consejos de seguridad para humanos (en español)"
}

Recuerda: Todos los textos deben ser en español, excepto los nombres científicos que permanecen en latín.

Enfócate en:
- Identificación precisa
- Evaluación de peligro (venenoso, tóxico, agresivo)
- Riesgos para la salud y enfermedades
- Precauciones de seguridad
- Hábitat y comportamiento

Sé exhaustivo pero conciso. Si no puedes identificar la especie, proporciona información general sobre el tipo de animal (en español).""";

      case 'hi':
        return """आप एक विशेषज्ञ एंटोमोलॉजिस्ट और हर्पेटोलॉजिस्ट हैं। इस कीट, मकड़ी, सांप, बिच्छू या अन्य छोटे जानवर की छवि का विश्लेषण करें और विस्तृत जानकारी प्रदान करें।

बहुत महत्वपूर्ण: सभी प्रतिक्रियाएं हिंदी में होनी चाहिए। केवल इस सटीक प्रारूप में एक वैध JSON प्रतिक्रिया लौटाएं, कोई अतिरिक्त पाठ नहीं:
{
  "name": "जानवर का सामान्य नाम (हिंदी में)",
  "species": "वैज्ञानिक नाम (लैटिन में रहता है)",
  "dangerLevel": "कम/मध्यम/उच्च",
  "description": "विस्तृत शारीरिक विवरण (हिंदी में)",
  "habitat": "यह कहाँ रहता है (हिंदी में)",
  "venomous": "हाँ/नहीं और विवरण (हिंदी में)",
  "diseases": "यह जो बीमारियां ले जा सकता है या पैदा कर सकता है (हिंदी में)",
  "safetyTips": "मनुष्यों के लिए सुरक्षा सलाह (हिंदी में)"
}

याद रखें: सभी पाठ हिंदी में होने चाहिए, केवल वैज्ञानिक नाम लैटिन में रहते हैं।

ध्यान केंद्रित करें:
- सटीक पहचान
- खतरे का मूल्यांकन (जहरीला, विषैला, आक्रामक)
- स्वास्थ्य जोखिम और बीमारियां
- सुरक्षा सावधानियां
- आवास और व्यवहार

व्यापक लेकिन संक्षिप्त रहें। यदि आप प्रजाति की पहचान नहीं कर सकते, तो जानवर के प्रकार के बारे में सामान्य जानकारी प्रदान करें (हिंदी में)।""";

      case 'ar':
        return """أنت خبير في علم الحشرات وعلم الزواحف. حلل هذه الصورة للحشرة أو العنكبوت أو الثعبان أو العقرب أو الحيوان الصغير الآخر وقدم معلومات مفصلة.

مهم جداً: يجب أن تكون جميع الإجابات باللغة العربية فقط. أعد استجابة JSON صالحة فقط بهذا التنسيق الدقيق، بدون نص إضافي:
{
  "name": "الاسم الشائع للحيوان باللغة العربية",
  "species": "الاسم العلمي (يبقى باللاتينية)",
  "dangerLevel": "منخفض/متوسط/عالي",
  "description": "وصف بدني مفصل باللغة العربية",
  "habitat": "أين يعيش (باللغة العربية)",
  "venomous": "نعم/لا والتفاصيل باللغة العربية",
  "diseases": "الأمراض التي يمكن أن يحملها أو يسببها (باللغة العربية)",
  "safetyTips": "نصائح السلامة للبشر (باللغة العربية)"
}

تذكر: جميع النصوص يجب أن تكون باللغة العربية، باستثناء الأسماء العلمية التي تبقى باللاتينية.

ركز على:
- التعريف الدقيق
- تقييم الخطر (سام، سام، عدواني)
- المخاطر الصحية والأمراض
- احتياطات السلامة
- الموطن والسلوك

كن شاملاً ولكن موجزاً. إذا لم تتمكن من تحديد النوع، قدم معلومات عامة عن نوع الحيوان باللغة العربية.""";

      case 'id':
        return """Anda adalah ahli entomologi dan herpetologi. Analisis gambar serangga, laba-laba, ular, kalajengking, atau hewan kecil lainnya ini dan berikan informasi detail.

SANGAT PENTING: Semua respons harus dalam bahasa Indonesia. Kembalikan HANYA respons JSON yang valid dalam format yang tepat ini, tanpa teks tambahan:
{
  "name": "Nama umum hewan (dalam bahasa Indonesia)",
  "species": "Nama ilmiah (tetap dalam bahasa Latin)",
  "dangerLevel": "rendah/sedang/tinggi",
  "description": "Deskripsi fisik detail (dalam bahasa Indonesia)",
  "habitat": "Di mana ia hidup (dalam bahasa Indonesia)",
  "venomous": "Ya/Tidak dan detail (dalam bahasa Indonesia)",
  "diseases": "Penyakit yang dapat dibawa atau disebabkan (dalam bahasa Indonesia)",
  "safetyTips": "Saran keselamatan untuk manusia (dalam bahasa Indonesia)"
}

Ingat: Semua teks harus dalam bahasa Indonesia, hanya nama ilmiah yang tetap dalam bahasa Latin.

Fokus pada:
- Identifikasi akurat
- Penilaian bahaya (beracun, beracun, agresif)
- Risiko kesehatan dan penyakit
- Tindakan pencegahan keselamatan
- Habitat dan perilaku

Jadilah menyeluruh tetapi ringkas. Jika Anda tidak dapat mengidentifikasi spesies, berikan informasi umum tentang jenis hewan (dalam bahasa Indonesia).""";

      case 'vi':
        return """Bạn là một chuyên gia về côn trùng học và bò sát học. Phân tích hình ảnh này của một con côn trùng, nhện, rắn, bọ cạp hoặc động vật nhỏ khác và cung cấp thông tin chi tiết.

RẤT QUAN TRỌNG: Tất cả phản hồi phải bằng tiếng Việt. Chỉ trả về phản hồi JSON hợp lệ trong định dạng chính xác này, không có văn bản bổ sung:
{
  "name": "Tên thông thường của động vật (bằng tiếng Việt)",
  "species": "Tên khoa học (giữ nguyên tiếng Latin)",
  "dangerLevel": "thấp/trung bình/cao",
  "description": "Mô tả thể chất chi tiết (bằng tiếng Việt)",
  "habitat": "Nơi nó sống (bằng tiếng Việt)",
  "venomous": "Có/Không và chi tiết (bằng tiếng Việt)",
  "diseases": "Bệnh mà nó có thể mang hoặc gây ra (bằng tiếng Việt)",
  "safetyTips": "Lời khuyên an toàn cho con người (bằng tiếng Việt)"
}

Nhớ: Tất cả văn bản phải bằng tiếng Việt, chỉ tên khoa học giữ nguyên tiếng Latin.

Tập trung vào:
- Nhận dạng chính xác
- Đánh giá nguy hiểm (độc, độc hại, hung hăng)
- Rủi ro sức khỏe và bệnh tật
- Biện pháp phòng ngừa an toàn
- Môi trường sống và hành vi

Hãy toàn diện nhưng ngắn gọn. Nếu bạn không thể xác định loài, hãy cung cấp thông tin chung về loại động vật (bằng tiếng Việt).""";

      case 'ko':
        return """당신은 곤충학자이자 파충류학자입니다. 이 곤충, 거미, 뱀, 전갈 또는 기타 작은 동물의 이미지를 분석하고 자세한 정보를 제공하세요.

매우 중요: 모든 응답은 한국어여야 합니다. 이 정확한 형식으로만 유효한 JSON 응답을 반환하고, 추가 텍스트는 포함하지 마세요:
{
  "name": "동물의 일반적인 이름 (한국어)",
  "species": "학명 (라틴어로 유지)",
  "dangerLevel": "낮음/중간/높음",
  "description": "자세한 신체 설명 (한국어)",
  "habitat": "어디에 사는지 (한국어)",
  "venomous": "예/아니오 및 세부사항 (한국어)",
  "diseases": "전파하거나 일으킬 수 있는 질병 (한국어)",
  "safetyTips": "인간을 위한 안전 조언 (한국어)"
}

기억하세요: 모든 텍스트는 한국어여야 하며, 학명만 라틴어로 유지됩니다.

다음에 집중하세요:
- 정확한 식별
- 위험 평가 (독성, 독성, 공격적)
- 건강 위험 및 질병
- 안전 예방책
- 서식지 및 행동

포괄적이지만 간결하게. 종을 식별할 수 없는 경우 동물 유형에 대한 일반적인 정보를 제공하세요 (한국어).""";

      case 'ja':
        return """あなたは昆虫学者であり爬虫類学者です。この昆虫、クモ、ヘビ、サソリ、または他の小さな動物の画像を分析し、詳細な情報を提供してください。

非常に重要：すべての応答は日本語でなければなりません。この正確な形式でのみ有効なJSON応答を返し、追加のテキストは含めないでください：
{
  "name": "動物の一般的な名前（日本語）",
  "species": "学名（ラテン語のまま）",
  "dangerLevel": "低/中/高",
  "description": "詳細な身体的特徴の説明（日本語）",
  "habitat": "生息地（日本語）",
  "venomous": "はい/いいえと詳細（日本語）",
  "diseases": "運ぶまたは引き起こす可能性のある病気（日本語）",
  "safetyTips": "人間のための安全アドバイス（日本語）"
}

覚えておいてください：すべてのテキストは日本語でなければならず、学名のみラテン語のままです。

以下に焦点を当ててください：
- 正確な識別
- 危険性の評価（毒、有毒、攻撃的）
- 健康リスクと病気
- 安全予防措置
- 生息地と行動

包括的だが簡潔に。種を特定できない場合は、動物の種類に関する一般的な情報を提供してください（日本語）。""";

      default: // English
        return """You are an expert entomologist and herpetologist. Analyze this image of an insect, spider, snake, scorpion, or other small animal and provide detailed information.

VERY IMPORTANT: All responses must be in English. Return ONLY a valid JSON response in this exact format, no additional text:
{
  "name": "Common name of the animal (in English)",
  "species": "Scientific name (remains in Latin)",
  "dangerLevel": "low/medium/high",
  "description": "Detailed physical description (in English)",
  "habitat": "Where it lives (in English)",
  "venomous": "Yes/No and details (in English)",
  "diseases": "Diseases it can carry or cause (in English)",
  "safetyTips": "Safety advice for humans (in English)"
}

Remember: All text must be in English, only scientific names remain in Latin.

Focus on:
- Accurate identification
- Danger assessment (venomous, poisonous, aggressive)
- Health risks and diseases
- Safety precautions
- Habitat and behavior

Be thorough but concise. If you cannot identify the species, provide general information about the type of animal (in English).""";
    }
  }

  Future<BugAnalysisResult> analyzeBugWithGemini(String base64Image, String languageCode) async {
    final prompt = _getPromptForLanguage(languageCode);
    
    final response = await http.post(
      Uri.parse(_endpoint + _apiKey),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": prompt
              },
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }
        ]
      }),
    );

    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'];
      
      print('Raw API Text: $text');
      
      // Extract JSON from text flexibly
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}');
      
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonString = text.substring(jsonStart, jsonEnd + 1);
        try {
          final jsonData = jsonDecode(jsonString);
          print('Parsed JSON: $jsonData');
          return BugAnalysisResult.fromJson(jsonData);
        } catch (e) {
          print('JSON Parse Error: $e');
          throw Exception('API response could not be parsed as JSON:\n$jsonString');
        }
      } else {
        print('No JSON found in response');
        throw Exception('API response is not in expected format:\n$text');
      }
    } else {
      print('API Error Status: ${response.statusCode}');
      print('API Error Body: ${response.body}');
      throw Exception('API Error (${response.statusCode}): \n${response.body}');
    }
  }
} 