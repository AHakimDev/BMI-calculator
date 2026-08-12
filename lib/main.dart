import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _preloadFonts() async {
  // بارگذاری هر دو خانواده فونت برای وب تا در هنگام سوئیچ کردن لرزش نداشته باشیم
  final vazirLoader = FontLoader('Vazirmatn');
  vazirLoader.addFont(rootBundle.load('assets/fonts/Vazirmatn-Regular.ttf'));
  vazirLoader.addFont(rootBundle.load('assets/fonts/Vazirmatn-Bold.ttf'));
  
  final poppinsLoader = FontLoader('Poppins');
  poppinsLoader.addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
  poppinsLoader.addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
  
  await Future.wait([
    vazirLoader.load(),
    poppinsLoader.load(),
  ]);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // قرار دادن فارسی به عنوان زبان پیش‌فرض
  if (!prefs.containsKey('isFarsi')) {
    await prefs.setBool('isFarsi', true);
  }
  
  bool savedLanguage = prefs.getBool('isFarsi') ?? true;
  
  // بارگذاری فونت‌ها قبل از اجرای برنامه
  await _preloadFonts();
  
  runApp(BMICalculatorApp(initialLanguage: savedLanguage));
}

class BMICalculatorApp extends StatefulWidget {
  final bool initialLanguage;
  const BMICalculatorApp({super.key, required this.initialLanguage});

  @override
  State<BMICalculatorApp> createState() => _BMICalculatorAppState();
}

class _BMICalculatorAppState extends State<BMICalculatorApp> {
  late bool isFarsi;

  @override
  void initState() {
    super.initState();
    isFarsi = widget.initialLanguage;
  }

  void toggleLanguage() async {
    setState(() {
      isFarsi = !isFarsi;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFarsi', isFarsi);
  }

  @override
  Widget build(BuildContext context) {
    String defaultFont = isFarsi ? 'Vazirmatn' : 'Poppins';
    String headerFont = isFarsi ? 'Vazirmatn' : 'Poppins';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      title: 'BMI Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: defaultFont,
        fontFamilyFallback: const ['Vazirmatn', 'Poppins', 'Roboto', 'Arial', 'sans-serif'],
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0A0E21),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: headerFont,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardColor: const Color(0xFF1D1E33),
        colorScheme: ColorScheme.dark(
          primary: Colors.tealAccent.shade400,
          secondary: Colors.tealAccent,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white, fontFamily: defaultFont),
        ),
      ),
      home: Container(
        color: const Color(0xFF0A0E21),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Directionality(
              textDirection: isFarsi ? TextDirection.rtl : TextDirection.ltr,
              child: BmiScreen(
                isFarsi: isFarsi,
                onToggleLanguage: toggleLanguage,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BmiScreen extends StatefulWidget {
  final bool isFarsi;
  final VoidCallback onToggleLanguage;

  const BmiScreen({
    super.key,
    required this.isFarsi,
    required this.onToggleLanguage,
  });

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  String selectedGender = 'male';
  double height = 170;
  int weight = 70;
  int age = 25;

  String bmiResult = '';
  String bmiStatus = '';
  Color bmiColor = Colors.transparent;
  String bmiAnalysis = '';
  double rawBmi = 0;

  List<BmiRecord> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? historyJson = prefs.getString('bmi_history');
    if (historyJson != null) {
      List<dynamic> decoded = jsonDecode(historyJson);
      setState(() {
        history = decoded.map((item) => BmiRecord.fromJson(item)).toList();
      });
    }
  }

  void _saveRecord(BmiRecord record) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      history.insert(0, record);
      if (history.length > 10) history.removeLast();
    });
    await prefs.setString(
      'bmi_history',
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  String get txtTitle => widget.isFarsi ? 'محاسبه‌گر BMI' : 'BMI CALCULATOR';
  String get txtMale => widget.isFarsi ? 'مرد' : 'Male';
  String get txtFemale => widget.isFarsi ? 'زن' : 'Female';
  String get txtHeight => widget.isFarsi ? 'قد' : 'Height';
  String get txtWeight => widget.isFarsi ? 'وزن' : 'Weight';
  String get txtAge => widget.isFarsi ? 'سن' : 'Age';
  String get txtCm => widget.isFarsi ? ' سانتی‌متر' : ' CM';
  String get txtCalculate => widget.isFarsi ? 'محاسبه' : 'Calculate';
  String get txtDialogTitle => widget.isFarsi ? 'وضعیت شما' : 'Your status is';
  String get txtAnalyze => widget.isFarsi ? 'آنالیز' : 'Analyze';
  String get txtHistory => widget.isFarsi ? 'تاریخچه اخیر' : 'Recent History';
  String get txtNoHistory => widget.isFarsi ? 'هنوز محاسبه‌ای ثبت نشده' : 'No history yet';

  void calculateBMI() {
    double heightInMeter = height / 100;
    double bmi = weight / (heightInMeter * heightInMeter);
    final logic = BmiLogic(widget.isFarsi);
    String status = logic.getStatus(bmi);
    String bmiFormatted = bmi.toStringAsFixed(1);
    String bmiDisplay = BmiUtils.toPersianDigits(bmiFormatted, widget.isFarsi);

    String dialogBodyFont = widget.isFarsi ? 'Vazirmatn' : 'Poppins';
    String dialogTitleFont = widget.isFarsi ? 'Vazirmatn' : 'Poppins';

    showDialog(
      context: context,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Directionality(
            textDirection: widget.isFarsi ? TextDirection.rtl : TextDirection.ltr,
            child: Dialog(
              backgroundColor: const Color(0xFF1D1E33),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          txtDialogTitle,
                          style: TextStyle(fontFamily: dialogTitleFont, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'BMI = $bmiDisplay',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: dialogBodyFont),
                        ),
                        Text(
                          status,
                          style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary, fontFamily: dialogBodyFont),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              final advice = logic.getAdvice(bmi, height, weight, age, selectedGender);
                              final record = BmiRecord(
                                bmi: bmiFormatted,
                                status: status,
                                date: DateTime.now().toIso8601String(),
                                advice: advice,
                                rawBmi: bmi,
                              );
                              _saveRecord(record);

                              setState(() {
                                rawBmi = bmi;
                                bmiResult = bmiDisplay;
                                bmiStatus = status;
                                bmiAnalysis = advice;
                                if (bmi < 18.5) {
                                  bmiColor = Colors.blue;
                                } else if (bmi < 25) {
                                  bmiColor = Colors.green;
                                } else if (bmi < 30) {
                                  bmiColor = Colors.orange;
                                } else {
                                  bmiColor = Colors.red;
                                }
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              txtAnalyze,
                              style: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: widget.isFarsi ? null : 0,
                    right: widget.isFarsi ? 0 : null,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(txtTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                foregroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () {
                widget.onToggleLanguage();
                setState(() {
                  bmiResult = '';
                });
              },
              icon: const Icon(Icons.language, size: 20),
              label: Text(
                widget.isFarsi ? 'English' : 'فارسی',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: widget.isFarsi ? 'Poppins' : 'Vazirmatn',
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: GenderCard(
                      title: txtMale,
                      iconPath: 'assets/male.svg',
                      isSelected: selectedGender == 'male',
                      onTap: () => setState(() => selectedGender = 'male'),
                    ),
                  ),
                  Expanded(
                    child: GenderCard(
                      title: txtFemale,
                      iconPath: 'assets/woman.svg',
                      isSelected: selectedGender == 'female',
                      onTap: () => setState(() => selectedGender = 'female'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 6)],
                ),
                child: Column(
                  children: [
                    Text(txtHeight, style: const TextStyle(fontSize: 19)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          BmiUtils.toPersianDigits(height.toInt().toString(), widget.isFarsi),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        Text(txtCm, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    Slider(
                      value: height,
                      min: 120,
                      max: 240,
                      divisions: 120,
                      activeColor: Theme.of(context).colorScheme.primary,
                      inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      label: BmiUtils.toPersianDigits(height.toInt().toString(), widget.isFarsi),
                      onChanged: (val) => setState(() => height = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CounterCard(
                      title: txtWeight,
                      value: weight,
                      unit: widget.isFarsi ? ' کیلو' : ' kg',
                      isFarsi: widget.isFarsi,
                      min: 10,
                      max: 200,
                      onChanged: (val) => setState(() => weight = val),
                    ),
                  ),
                  Expanded(
                    child: CounterCard(
                      title: txtAge,
                      value: age,
                      unit: widget.isFarsi ? ' سال' : ' yr',
                      isFarsi: widget.isFarsi,
                      min: 1,
                      max: 120,
                      onChanged: (val) => setState(() => age = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: calculateBMI,
                  child: Text(
                    txtCalculate,
                    style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (bmiResult.isEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history, size: 18, color: Colors.white54),
                        const SizedBox(width: 8),
                        Text(txtHistory, style: const TextStyle(fontSize: 15, color: Colors.white70, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (history.isNotEmpty)
                      GestureDetector(
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.remove('bmi_history');
                          setState(() => history.clear());
                        },
                        child: Icon(Icons.delete_sweep, size: 20, color: Colors.red.withOpacity(0.7)),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (history.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(txtNoHistory, style: const TextStyle(color: Colors.white38, fontSize: 13)),
                    ),
                  )
                else
                  SizedBox(
                    height: 95,
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: history.length,
                        padding: const EdgeInsets.only(bottom: 12),
                        itemBuilder: (context, index) {
                          final record = history[index];
                          Color rColor = Colors.tealAccent;
                          double bVal = double.tryParse(record.bmi) ?? 0;
                          if (bVal < 18.5) {
                            rColor = Colors.blueAccent;
                          } else if (bVal < 25) {
                            rColor = Colors.greenAccent;
                          } else if (bVal < 30) {
                            rColor = Colors.orangeAccent;
                          } else {
                            rColor = Colors.redAccent;
                          }

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                bmiResult = BmiUtils.toPersianDigits(record.bmi, widget.isFarsi);
                                bmiStatus = record.status;
                                bmiAnalysis = record.advice;
                                rawBmi = record.rawBmi;
                                if (rawBmi < 18.5) {
                                  bmiColor = Colors.blue;
                                } else if (rawBmi < 25) {
                                  bmiColor = Colors.green;
                                } else if (rawBmi < 30) {
                                  bmiColor = Colors.orange;
                                } else {
                                  bmiColor = Colors.red;
                                }
                              });
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 115,
                                  margin: const EdgeInsets.only(left: 10, right: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: rColor.withOpacity(0.2)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          BmiUtils.toPersianDigits(record.bmi, widget.isFarsi),
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: rColor),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          record.status,
                                          style: const TextStyle(fontSize: 11, color: Colors.white60),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (index == 0)
                                  Positioned(
                                    top: 4,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.tealAccent.shade700.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          widget.isFarsi ? 'جدیدترین' : 'LATEST',
                                          style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.white),
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
                  ),
              ],
              if (bmiResult.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutQuart,
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  decoration: BoxDecoration(
                    color: bmiColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: bmiColor.withOpacity(0.5), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 32),
                          Text(txtAnalyze,
                              style: TextStyle(fontSize: 14, color: bmiColor.withOpacity(0.8), fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18, color: Colors.white54),
                            onPressed: () => setState(() => bmiResult = ''),
                          ),
                        ],
                      ),
                      Text('BMI = $bmiResult', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: bmiColor)),
                      const SizedBox(height: 12),
                      BmiGauge(bmi: rawBmi),
                      const SizedBox(height: 16),
                      Text(bmiStatus, style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: bmiColor)),
                      const SizedBox(height: 10),
                      Text(
                        bmiAnalysis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class BmiGauge extends StatelessWidget {
  final double bmi;
  const BmiGauge({super.key, required this.bmi});

  @override
  Widget build(BuildContext context) {
    double constrainedBmi = bmi.clamp(15.0, 40.0);
    double percent = (constrainedBmi - 15) / (40 - 15);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          SizedBox(
            height: 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.green, Colors.orange, Colors.red],
                      stops: [0.1, 0.4, 0.7, 0.9],
                    ),
                  ),
                ),
                AnimatedAlign(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  alignment: Alignment(percent * 2 - 1, 0),
                  child: Container(
                    height: 20,
                    width: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('15', style: TextStyle(fontSize: 10, color: Colors.white38)),
              Text('25', style: TextStyle(fontSize: 10, color: Colors.white38)),
              Text('40', style: TextStyle(fontSize: 10, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }
}

class BmiRecord {
  final String bmi;
  final String status;
  final String date;
  final String advice;
  final double rawBmi;

  BmiRecord({
    required this.bmi,
    required this.status,
    required this.date,
    required this.advice,
    required this.rawBmi,
  });

  Map<String, dynamic> toJson() => {
    'bmi': bmi,
    'status': status,
    'date': date,
    'advice': advice,
    'rawBmi': rawBmi,
  };

  factory BmiRecord.fromJson(Map<String, dynamic> json) => BmiRecord(
    bmi: json['bmi'],
    status: json['status'],
    date: json['date'],
    advice: json['advice'] ?? '',
    rawBmi: (json['rawBmi'] ?? 0.0).toDouble(),
  );
}

class BmiUtils {
  static String toPersianDigits(String input, bool isFarsi) {
    if (!isFarsi) return input;
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], farsi[i]);
    }
    return input;
  }
}

class BmiLogic {
  final bool isFarsi;
  BmiLogic(this.isFarsi);

  String getStatus(double bmi) {
    if (isFarsi) {
      if (bmi < 18.5) return 'کمبود وزن';
      if (bmi < 25) return 'وزن سالم';
      if (bmi < 30) return 'اضافه وزن';
      return 'چاقی';
    } else {
      if (bmi < 18.5) return 'under weight';
      if (bmi < 25) return 'healthy weight';
      if (bmi < 30) return 'over weight';
      return 'obese';
    }
  }

  String getAdvice(double bmi, double heightCm, int weight, int age, String gender) {
    double heightM = heightCm / 100;
    double minHealthy = 18.5 * (heightM * heightM);
    double maxHealthy = 24.9 * (heightM * heightM);

    if (age < 20) {
      return isFarsi ? 'محدوده استاندارد BMI برای بزرگسالان طراحی شده. برای زیر ۲۰ سال با پزشک مشورت کنید.' : 'BMI standard ranges are designed for adults. For ages under 20, please consult a pediatrician.';
    }

    if (age >= 60 && bmi >= 18.5 && bmi <= 27) {
      return isFarsi ? 'برای افراد بالای ۶۰ سال، BMI تا ۲۷ قابل قبول است. شما در محدوده سالم هستید.' : 'For adults over 60, a BMI up to 27 is acceptable. You are within a healthy range.';
    }

    if (bmi < 18.5) {
      double gain = minHealthy - weight;
      if (gender == 'female') {
        return isFarsi ? 'باید ${gain.toStringAsFixed(1)} کیلوگرم اضافه کنید. بر روی غذاهای مغذی تمرکز کنید.' : 'You need to gain ${gain.toStringAsFixed(1)} kg. Focus on nutrient-rich foods.';
      } else {
        return isFarsi ? 'باید ${gain.toStringAsFixed(1)} کیلوگرم اضافه کنید. تمرینات قدرتی و پروتئین توصیه می‌شود.' : 'You need to gain ${gain.toStringAsFixed(1)} kg. Focus on strength training and protein-rich nutrition.';
      }
    }

    if (bmi > 24.9) {
      double lose = weight - maxHealthy;
      if (gender == 'female') {
        return isFarsi ? 'باید ${lose.toStringAsFixed(1)} کیلوگرم کم کنید. ترکیب ورزش هوازی و رژیم غذایی توصیه می‌شود.' : 'You need to lose ${lose.toStringAsFixed(1)} kg. Cardio and balanced diet is recommended.';
      } else {
        return isFarsi ? 'باید ${lose.toStringAsFixed(1)} کیلوگرم کم کنید. تمرینات قدرتی همراه با کاهش کالری موثر است.' : 'You need to lose ${lose.toStringAsFixed(1)} kg. Strength training with caloric deficit is effective.';
      }
    }

    return isFarsi ? 'شما در محدوده سالم هستید. همینطور ادامه دهید!' : 'You are within the healthy BMI range. Keep up your balanced lifestyle!';
  }
}

class GenderCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  const GenderCard({super.key, required this.title, required this.iconPath, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 6)],
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              iconPath,
              height: 42,
              colorFilter: ColorFilter.mode(isSelected ? Theme.of(context).colorScheme.primary : Colors.white, BlendMode.srcIn),
            ),
            const SizedBox(height: 11),
            Text(title, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white, fontSize: 14.5)),
          ],
        ),
      ),
    );
  }
}

class CounterCard extends StatefulWidget {
  final String title;
  final int value;
  final String unit;
  final bool isFarsi;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const CounterCard({super.key, required this.title, required this.value, required this.unit, required this.isFarsi, required this.onChanged, this.min = 1, this.max = 200});

  @override
  State<CounterCard> createState() => _CounterCardState();
}

class _CounterCardState extends State<CounterCard> {
  Timer? _timer;

  void _updateValue(int delta) {
    int newValue = widget.value + delta;
    if (newValue >= widget.min && newValue <= widget.max) {
      widget.onChanged(newValue);
    }
  }

  void _startTimer(int delta) {
    _stopTimer();
    _updateValue(delta);
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => _updateValue(delta));
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 6)],
      ),
      child: Column(
        children: [
          Text(widget.title, style: const TextStyle(fontSize: 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(BmiUtils.toPersianDigits(widget.value.toString(), widget.isFarsi), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              Text(widget.unit, style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(Icons.remove, () => _startTimer(-1)),
              _buildControlButton(Icons.add, () => _startTimer(1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onLongPressStart) {
    return GestureDetector(
      onLongPressStart: (_) => onLongPressStart(),
      onLongPressEnd: (_) => _stopTimer(),
      onTap: () {
        _startTimer(icon == Icons.add ? 1 : -1);
        _stopTimer();
      },
      child: Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}