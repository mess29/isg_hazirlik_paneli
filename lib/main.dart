import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// --- YAPAY ZEKA AYARLARI ---
const String geminiApiKey = "AIzaSyBsl0y7sqPBrRi0fBVCoZk5QOm0yZzBQbg"; 
const String geminiModel = "gemini-2.5-flash";

// --- GLOBAL STATE ---
// Soru tarzını (Klasik / Yeni Nesil) tüm uygulamada takip etmek için
final ValueNotifier<String> globalQuestionStyle = ValueNotifier('new_gen');

void main() {
  runApp(const ISGPrepApp());
}

class ISGPrepApp extends StatelessWidget {
  const ISGPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İSG 2026 Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Blue 600
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFFF59E0B), // Amber 500
          surface: Colors.white,
          background: const Color(0xFFF8FAFC), // grey 50
        ),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const TopicListScreen(),
    const StudyPlanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Panel'),
            BottomNavigationBarItem(icon: Icon(Icons.book_rounded), label: 'Konular'),
            BottomNavigationBarItem(icon: Icon(Icons.schedule_rounded), label: 'Plan'),
          ],
        ),
      ),
    );
  }
}

// --- Dashboard ---
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime examDate = DateTime(2026, 5, 16);
    final int daysLeft = examDate.difference(DateTime.now()).inDays;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 8)],
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('İSG 2026', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 22)),
            const Text(' Pro', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2563EB), fontSize: 22)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Alert
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)]),
                border: Border.all(color: const Color(0xFFFDE68A)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Yeni Kurum Adaptasyonu Aktif', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF78350F), fontSize: 13)),
                        SizedBox(height: 4),
                        Text('ÖSYM dışı kurumların hazırlayacağı sınavlar için "Vaka Analizi" soruları eklendi.', style: TextStyle(color: Color(0xFF92400E), fontSize: 12, height: 1.4)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Welcome Header
            const Text('Hoş Geldiniz, Uzman Adayı', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
            const SizedBox(height: 4),
            const Text('"Güvenliğin yolu doğru bilgiden geçer."', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),

            // Question Style Toggle
            ValueListenableBuilder<String>(
              valueListenable: globalQuestionStyle,
              builder: (context, style, child) {
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200.withOpacity(0.5), blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => globalQuestionStyle.value = 'classic',
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: style == 'classic' ? Colors.grey.shade100 : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(child: Text('KLASİK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: style == 'classic' ? const Color(0xFF1E293B) : Colors.grey.shade400))),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => globalQuestionStyle.value = 'new_gen',
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: style == 'new_gen' ? const Color(0xFF2563EB) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: style == 'new_gen' ? [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                            ),
                            child: Center(child: Text('YENİ NESİL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: style == 'new_gen' ? Colors.white : Colors.grey.shade400))),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
            const SizedBox(height: 24),

            // Topics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildTopicCard(context, 'İş Hukuku ve Mevzuat', '%30', Icons.menu_book_rounded, const Color(0xFF2563EB)),
                _buildTopicCard(context, 'Teknik Konular', '%40', Icons.settings_rounded, const Color(0xFF2563EB)),
                _buildTopicCard(context, 'Sağlık ve Meslek Has.', '%20', Icons.health_and_safety_rounded, const Color(0xFF2563EB)),
                _buildTopicCard(context, 'Risk Analizi ve Yön.', '%10', Icons.analytics_rounded, const Color(0xFF2563EB)),
              ],
            ),
            const SizedBox(height: 32),

            // Strategy Box
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3))),
                        child: const Icon(Icons.bolt_rounded, color: Color(0xFF60A5FA), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text('Günün Stratejisi', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '"Yeni nesil sorularda işverenin maliyet yerine güvenlik odaklı kararları tercih etmesi beklenir. Cevap ararken her zaman hiyerarşinin en üstündeki Kaynağında Yok Etme ilkesini arayın."',
                    style: TextStyle(color: Color(0xFFDBEAFE), fontSize: 15, height: 1.5, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, String title, String weight, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TestScreen(topic: title))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, color: Colors.grey.shade600, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                  child: Text('Ağırlık: $weight', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey.shade600)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 16, height: 1.2)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('BAŞLAT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF2563EB), letterSpacing: 1)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF2563EB)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// --- Topic List ---
class TopicListScreen extends StatefulWidget {
  const TopicListScreen({super.key});

  @override
  State<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  String _searchTerm = "";

  final List<Map<String, dynamic>> detailedTopicList = [
    {
      "category": "Hukuk ve Mevzuat",
      "items": [
        "6331 Sayılı İş Sağlığı ve Güvenliği Kanunu",
        "4857 Sayılı İş Kanunu (İlgili Maddeler)",
        "5510 Sayılı Sosyal Sigortalar Kanunu",
        "6098 Sayılı Türk Borçlar Kanunu",
        "İSG Kurulları Hakkında Yönetmelik",
        "Risk Değerlendirmesi Yönetmeliği"
      ]
    },
    {
      "category": "Teknik Konular",
      "items": [
        "Fiziksel Risk Etmenleri",
        "Kimyasal Risk Etmenleri ve MSDS",
        "Biyolojik Risk Etmenleri",
        "İş Ekipmanları Güvenliği",
        "Kaldırma Araçları ve İstifleme",
        "Basınçlı Kaplar",
        "Elektrikle Çalışmalarda İSG",
        "İnşaat İşlerinde İSG",
        "Maden İşyerlerinde İSG"
      ]
    },
    {
      "category": "Sağlık Konuları",
      "items": [
        "Meslek Hastalıkları",
        "Toksikoloji",
        "Epidemiyoloji",
        "İş Fizyolojisi ve Ergonomi",
        "İlkyardım Temel Prensipleri"
      ]
    },
    {
      "category": "Yönetim ve Metodoloji",
      "items": [
        "Risk Değerlendirmesi Metodolojileri",
        "ISO 45001 Yönetim Sistemleri",
        "Güvenlik Kültürü",
        "İş Kazası Analizi ve Kök Neden"
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: const Text('Sınav Müfredatı', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 24)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tüm konulara hakimiyet, başarıyı getirir.', style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10)],
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchTerm = val),
                decoration: InputDecoration(
                  hintText: 'Konu veya yönetmelik ara...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Categories
            ...detailedTopicList.map((cat) {
              List<String> items = List<String>.from(cat['items']);
              List<String> filtered = items.where((i) => i.toLowerCase().contains(_searchTerm.toLowerCase())).toList();
              
              if (_searchTerm.isNotEmpty && filtered.isEmpty) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.grey.shade50, blurRadius: 5)],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cat['category'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5, color: Color(0xFF1E293B))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(20)),
                            child: Text('${filtered.length} MADDE', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF1D4ED8))),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: filtered.map((item) => ListTile(
                          leading: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle)),
                          minLeadingWidth: 10,
                          title: Text(item, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155), fontSize: 14)),
                          dense: true,
                        )).toList(),
                      ),
                    )
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 20),
            
            // Genel Deneme Sınavı Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF312E81)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, color: Color(0xFFFBBF24), size: 14),
                        SizedBox(width: 4),
                        Text('TAM KAPSAMLI MOD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Genel Deneme Sınavı', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                  const SizedBox(height: 16),
                  const Text(
                    'Tüm müfredatı kapsayan, konu ağırlıklarına göre dağıtılmış ve her seferinde tamamen farklı sorulardan oluşan 10 soruluk simülasyon.',
                    style: TextStyle(color: Color(0xFFDBEAFE), fontSize: 15, height: 1.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TestScreen(topic: null))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('ŞİMDİ DENEMEYİ BAŞLAT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// --- Modeller ---
class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String difficulty;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      explanation: json['explanation'] ?? '',
      difficulty: json['difficulty'] ?? 'Orta',
    );
  }
}

// --- Test Ekranı (Gemini Birebir React Mantığı) ---
class TestScreen extends StatefulWidget {
  final String? topic; // null ise Genel Deneme
  const TestScreen({super.key, this.topic});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool _loading = true;
  List<Question> _questions = [];
  Map<int, int> _userAnswers = {};
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    if (geminiApiKey.isEmpty) {
      setState(() {
        _errorMessage = "Lütfen kodun başındaki API Anahtarını doldurun.";
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = "";
      _userAnswers = {};
      _questions = [];
    });

    final bool isGeneral = widget.topic == null;
    final String currentStyle = globalQuestionStyle.value;
    
    final String styleInstruction = currentStyle == 'new_gen'
        ? "ÖNEMLİ: Sınavı ÖSYM hazırlamayacağı için soruları akademik ve senaryo odaklı hazırla. 'Bir iş yerinde X durumu yaşanıyor...' gibi vakalar üzerinden uzmanlık yorumu gerektiren, sadece ezber değil mantık yürüten sorular olsun."
        : "Klasik ÖSYM tarzı: Net mevzuat bilgisi, süreler ve rakamlar üzerine odaklan.";

    final String distributionNote = isGeneral
        ? "Bu bir GENEL DENEME sınavıdır. Mevzuat (%30), Teknik (%40), Sağlık (%20) ve Yönetim (%10) ağırlıklarına sadık kalarak toplam 10 soru üret."
        : "Seçilen konu: \"${widget.topic}\". Bu konuya odaklanarak 5 soru üret.";

    final String systemPrompt = """Sen profesyonel bir İSG Eğitmenisin. 16 Mayıs 2026 sınavı için soru hazırlıyorsun.
$distributionNote
$styleInstruction
Lütfen çoktan seçmeli sorular oluştur. Soruların sonunda doğru cevap anahtarını (A, B, C, D veya E şeklinde) ve detaylı akademik açıklamalarını ekle. Her soru için zorluk seviyesini belirt. Yanıt kesinlikle JSON formatında olmalıdır.""";

    final String userQuery = isGeneral
        ? "Bana tüm müfredatı kapsayan karma, her seferinde değişen ${currentStyle == 'new_gen' ? 'yeni nesil' : 'klasik'} 10 soruluk bir deneme seti üret."
        : "Bana ${widget.topic} konusuyla ilgili 5 soru üret.";

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{"parts": [{"text": userQuery}]}],
          "systemInstruction": {"parts": [{"text": systemPrompt}]},
          "generationConfig": {
            "responseMimeType": "application/json",
            "responseSchema": {
              "type": "OBJECT",
              "properties": {
                "test": {
                  "type": "ARRAY",
                  "items": {
                    "type": "OBJECT",
                    "properties": {
                      "question": {"type": "STRING"},
                      "options": {"type": "ARRAY", "items": {"type": "STRING"}},
                      "correctAnswer": {"type": "STRING"},
                      "explanation": {"type": "STRING"},
                      "difficulty": {"type": "STRING"}
                    },
                    "required": ["question", "options", "correctAnswer", "explanation"]
                  }
                }
              }
            }
          }
        }),
      ).timeout(const Duration(seconds: 45)); // Karmaşık denemeler için timeout süresi artırıldı

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String text = data['candidates'][0]['content']['parts'][0]['text'];
        final parsed = jsonDecode(text);
        
        if (parsed['test'] != null && parsed['test'] is List) {
           setState(() {
            _questions = (parsed['test'] as List).map((i) => Question.fromJson(i)).toList();
            _loading = false;
          });
        } else {
           throw Exception("Geçersiz JSON yapısı");
        }
      } else {
        throw Exception("API Hatası: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Soru üretilirken bir hata oluştu. Lütfen tekrar deneyiniz.\nHata Detayı: $e";
        _loading = false;
      });
    }
  }

  void _handleAnswer(int questionIndex, int optionIndex) {
    if (_userAnswers.containsKey(questionIndex)) return; // Sadece bir kere cevaplanabilir
    setState(() {
      _userAnswers[questionIndex] = optionIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.topic == null ? 'GENEL DENEME' : 'KONU TESTİ', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 14, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(strokeWidth: 8, color: Color(0xFF2563EB), backgroundColor: Color(0xFFEFF6FF)),
                  ),
                  const SizedBox(height: 30),
                  const Text('Sınav Kağıdı Hazırlanıyor', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  Text(widget.topic == null ? 'Müfredat taranıyor, 10 karma soru üretiliyor...' : 'Güncel mevzuata uygun 5 soru üretiliyor...', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(30),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.redAccent.shade100, shape: BoxShape.circle), child: const Icon(Icons.error_outline_rounded, size: 60, color: Color(0xFFE11D48))),
                        const SizedBox(height: 24),
                        Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16)),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _fetchQuestions, 
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                          child: const Text('TEKRAR DENE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Header Area
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: BorderRadius.circular(20)),
                            child: Text(globalQuestionStyle.value == 'new_gen' ? 'AKADEMİK SENARYO' : 'BİLGİ ANALİZİ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
                          ),
                          const SizedBox(height: 20),
                          Text(widget.topic ?? 'Genel Deneme Sınavı', textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2)),
                          const SizedBox(height: 12),
                          const Text('SİMÜLASYON AKTİF', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 3)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Questions Loop
                    ...List.generate(_questions.length, (qIdx) {
                      final q = _questions[qIdx];
                      final int? selectedOptIdx = _userAnswers[qIdx];
                      final bool hasAnswered = selectedOptIdx != null;
                      final bool isCorrectOverall = hasAnswered && String.fromCharCode(65 + selectedOptIdx) == q.correctAnswer;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question Header
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: hasAnswered ? (isCorrectOverall ? const Color(0xFF059669) : const Color(0xFFE11D48)) : const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
                                  ),
                                  child: Text('${qIdx + 1}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('ZORLUK: ${q.difficulty.toUpperCase()}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: q.difficulty == 'Zor' ? const Color(0xFFE11D48) : const Color(0xFF059669))),
                                      const SizedBox(height: 8),
                                      Text(q.question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), height: 1.4)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // Options Loop
                            Padding(
                              padding: const EdgeInsets.only(left: 68), // Align with text
                              child: Column(
                                children: List.generate(q.options.length, (oIdx) {
                                  final String char = String.fromCharCode(65 + oIdx);
                                  final bool isThisCorrect = char == q.correctAnswer;
                                  final bool isThisSelected = selectedOptIdx == oIdx;

                                  Color bgColor = Colors.white;
                                  Color borderColor = Colors.grey.shade200;
                                  Color charBgColor = Colors.grey.shade50;
                                  Color charTextColor = Colors.grey.shade500;
                                  Color textColor = const Color(0xFF334155);

                                  if (hasAnswered) {
                                    if (isThisCorrect) {
                                      bgColor = const Color(0xFFECFDF5);
                                      borderColor = const Color(0xFF10B981);
                                      charBgColor = const Color(0xFF059669);
                                      charTextColor = Colors.white;
                                      textColor = const Color(0xFF064E3B);
                                    } else if (isThisSelected && !isThisCorrect) {
                                      bgColor = const Color(0xFFFFF1F2);
                                      borderColor = const Color(0xFFF43F5E);
                                      charBgColor = const Color(0xFFE11D48);
                                      charTextColor = Colors.white;
                                      textColor = const Color(0xFF881337);
                                    } else {
                                      bgColor = Colors.grey.shade50;
                                      borderColor = Colors.grey.shade100;
                                      charBgColor = Colors.grey.shade100;
                                      charTextColor = Colors.grey.shade300;
                                      textColor = Colors.grey.shade400;
                                    }
                                  }

                                  return GestureDetector(
                                    onTap: () => _handleAnswer(qIdx, oIdx),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: borderColor, width: hasAnswered && (isThisCorrect || isThisSelected) ? 2 : 1),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(color: charBgColor, borderRadius: BorderRadius.circular(12)),
                                            child: Text(char, style: TextStyle(fontWeight: FontWeight.w900, color: charTextColor, fontSize: 16)),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(child: Text(q.options[oIdx], style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: textColor, height: 1.3))),
                                          if (hasAnswered && isThisCorrect)
                                            const Icon(Icons.check_circle_rounded, color: Color(0xFF059669)),
                                          if (hasAnswered && isThisSelected && !isThisCorrect)
                                            const Icon(Icons.cancel_rounded, color: Color(0xFFE11D48)),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),

                            // Explanation Area (Auto opens when answered)
                            if (hasAnswered)
                              Padding(
                                padding: const EdgeInsets.only(left: 68, top: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
                                          const SizedBox(width: 8),
                                          Text('DOĞRU CEVAP: ${q.correctAnswer}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF064E3B))),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(q.explanation, style: const TextStyle(fontSize: 15, height: 1.6, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                      ),
                      );
                    }),

                    // Bottom Action Buttons
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchQuestions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 10,
                        shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('YENİ SORULAR ÜRET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1)),
                          SizedBox(width: 8),
                          Icon(Icons.bolt_rounded, color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('TESTİ TAMAMLA VE KAYDET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1)),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
    );
  }
}

// --- Çalışma Planı ---
class StudyPlanScreen extends StatelessWidget {
  const StudyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: const Text('70 Günlük Strateji', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 24)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Zamanı yöneten, sınavı yönetir.', style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 30),
          _buildTimelineItem('1-15. Gün', 'Kavramsal Temeller', 'Hiyerarşi, temel kanunlar ve yönetmelik mantığı.', Icons.account_tree_rounded),
          _buildTimelineItem('16-40. Gün', 'Teknik ve Senaryo', 'Ekipmanlar, inşaat, maden ve vaka analizleri.', Icons.engineering_rounded),
          _buildTimelineItem('41-60. Gün', 'Akademik Mevzuat', 'ISO standartları, sağlık limitleri ve ince detaylar.', Icons.menu_book_rounded),
          _buildTimelineItem('Son 10 Gün', 'Simülasyon Maratonu', 'Her gün 3 genel deneme ve hızlı mevzuat taraması.', Icons.emoji_events_rounded, isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String days, String title, String desc, IconData icon, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10, offset: const Offset(0, 5))]),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            if (!isLast)
              Container(width: 2, height: 60, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(vertical: 8)),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 30),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(days, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2563EB), fontSize: 11, letterSpacing: 2)),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500, height: 1.4)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}