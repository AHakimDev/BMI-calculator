import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart'; // این خط اضافه شد

void main() async {
  // این خط به فلاتر می‌گوید قبل از اجرای اپلیکیشن، اجازه بده کدهای ناهمگام (مثل خواندن حافظه) کامل شوند
  WidgetsFlutterBinding.ensureInitialized();

  // خواندن اطلاعات از حافظه گوشی
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // کلیدی به نام 'isFarsi' را می‌خوانیم. اگر بار اول بود و چیزی پیدا نکرد، پیش‌فرض را false (انگلیسی) در نظر می‌گیرد
  bool savedLanguage = prefs.getBool('isFarsi') ?? false;

  // ارسال زبان ذخیره‌شده به اپلیکیشن
  runApp(BMICalculatorApp(initialLanguage: savedLanguage));
}

class BMICalculatorApp extends StatefulWidget {
  final bool initialLanguage; // متغیر جدید برای دریافت زبان اولیه

  const BMICalculatorApp({super.key, required this.initialLanguage});

  @override
  State<BMICalculatorApp> createState() => _BMICalculatorAppState();
}

class _BMICalculatorAppState extends State<BMICalculatorApp> {
  late bool isFarsi;

  @override
  void initState() {
    super.initState();
    // در زمان لود شدن برنامه، زبان را برابر با همان چیزی قرار می‌دهیم که از حافظه خوانده شده
    isFarsi = widget.initialLanguage;
  }

  // این تابع حالا ناهمگام (async) شده تا بتواند در حافظه بنویسد
  void toggleLanguage() async {
    setState(() {
      isFarsi = !isFarsi;
    });

    // بلافاصله بعد از تغییر زبان توسط کاربر، آن را در حافظه گوشی ذخیره می‌کنیم
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFarsi', isFarsi);
  }

  @override
  Widget build(BuildContext context) {
    // هوشمندسازی انتخاب فونت بر اساس زبان
    String defaultFont = isFarsi ? 'BNazanin' : 'ETimes';
    String headerFont = isFarsi ? 'BTitr' : 'ETimes';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMI Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: defaultFont, // فونت پیش‌فرض کل دکمه‌ها و متن‌های برنامه
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0A0E21),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: headerFont, // استفاده از فونت تیتر برای هدر بالا
              fontSize: 25,
              fontWeight: FontWeight.bold
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
      home: Directionality(
        textDirection: isFarsi ? TextDirection.rtl : TextDirection.ltr,
        child: BmiScreen(isFarsi: isFarsi, onToggleLanguage: toggleLanguage),
      ),
    );
  }
}

class BmiScreen extends StatefulWidget {
  final bool isFarsi;
  final VoidCallback onToggleLanguage;

  const BmiScreen({super.key, required this.isFarsi, required this.onToggleLanguage});

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

  // متغیر جدید برای نگهداری آخرین نتیجه
  String lastBmiResult = '';

  @override
  void initState() {
    super.initState();
    _loadLastBmi();
  }

  // تابعی که به محض باز شدن صفحه، حافظه را می‌خواند
  void _loadLastBmi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lastBmiResult = prefs.getString('last_bmi') ?? '';
    });
  }

  // ================= TEXT GETTERS =================
  String get txtTitle => widget.isFarsi ? 'محاسبه‌گر BMI' : 'BMI CALCULATOR';
  String get txtMale => widget.isFarsi ? 'مرد' : 'Male';
  String get txtFemale => widget.isFarsi ? 'زن' : 'Female';
  String get txtHeight => widget.isFarsi ? 'قد' : 'Height';
  String get txtWeight => widget.isFarsi ? 'وزن' : 'Weight';
  String get txtAge => widget.isFarsi ? 'سن' : 'Age';
  String get txtCm => widget.isFarsi ? ' سانتی‌متر' : ' CM';
  String get txtCalculate => widget.isFarsi ? 'محاسبه' : 'Calculate';
  String get txtDialogTitle => widget.isFarsi ? 'وضعیت شما' : 'Your status is';
  String get txtDismiss => widget.isFarsi ? 'بستن' : 'Dismiss';
  String get txtAnalyze => widget.isFarsi ? 'آنالیز' : 'Analyze';

  // ================= LOGIC METHODS =================
  String getBmiStatus(double bmi) {
    if (widget.isFarsi) {
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

  String getWeightAdvice(double bmi, double heightCm, int weight, int age, String gender) {
    double heightM = heightCm / 100;
    double minHealthy = 18.5 * (heightM * heightM);
    double maxHealthy = 24.9 * (heightM * heightM);

    if (age < 20) {
      return widget.isFarsi
          ? 'محدوده استاندارد BMI برای بزرگسالان طراحی شده. برای زیر ۲۰ سال با پزشک مشورت کنید.'
          : 'BMI standard ranges are designed for adults. For ages under 20, please consult a pediatrician.';
    }

    if (age >= 60 && bmi >= 18.5 && bmi <= 27) {
      return widget.isFarsi
          ? 'برای افراد بالای ۶۰ سال، BMI تا ۲۷ قابل قبول است. شما در محدوده سالم هستید.'
          : 'For adults over 60, a BMI up to 27 is acceptable. You are within a healthy range.';
    }

    if (bmi < 18.5) {
      double gain = minHealthy - weight;
      if (gender == 'female') {
        return widget.isFarsi
            ? 'باید ${gain.toStringAsFixed(1)} کیلوگرم اضافه کنید. بر روی غذاهای مغذی تمرکز کنید.'
            : 'You need to gain ${gain.toStringAsFixed(1)} kg. Focus on nutrient-rich foods.';
      } else {
        return widget.isFarsi
            ? 'باید ${gain.toStringAsFixed(1)} کیلوگرم اضافه کنید. تمرینات قدرتی و پروتئین توصیه می‌شود.'
            : 'You need to gain ${gain.toStringAsFixed(1)} kg. Focus on strength training and protein-rich nutrition.';
      }
    }

    if (bmi > 24.9) {
      double lose = weight - maxHealthy;
      if (gender == 'female') {
        return widget.isFarsi
            ? 'باید ${lose.toStringAsFixed(1)} کیلوگرم کم کنید. ترکیب ورزش هوازی و رژیم غذایی توصیه می‌شود.'
            : 'You need to lose ${lose.toStringAsFixed(1)} kg. Cardio and balanced diet is recommended.';
      } else {
        return widget.isFarsi
            ? 'باید ${lose.toStringAsFixed(1)} کیلوگرم کم کنید. تمرینات قدرتی همراه با کاهش کالری موثر است.'
            : 'You need to lose ${lose.toStringAsFixed(1)} kg. Strength training with caloric deficit is effective.';
      }
    }

    return widget.isFarsi
        ? 'شما در محدوده سالم هستید. همینطور ادامه دهید!'
        : 'You are within the healthy BMI range. Keep up your balanced lifestyle!';
  }

  void calculateBMI() {
    double heightInMeter = height / 100;
    double bmi = weight / (heightInMeter * heightInMeter);
    String status = getBmiStatus(bmi);

    // تشخیص فونت برای دیالوگ
    String dialogBodyFont = widget.isFarsi ? 'BNazanin' : 'ETimes';
    String dialogTitleFont = widget.isFarsi ? 'BTitr' : 'ETimes';

    showCupertinoDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: widget.isFarsi ? TextDirection.rtl : TextDirection.ltr,
        child: CupertinoAlertDialog(
          title: Text(txtDialogTitle, style: TextStyle(fontFamily: dialogTitleFont, fontSize: 20)),
          content: Text('BMI = ${bmi.toStringAsFixed(1)}\n$status',
              style: TextStyle(fontSize: 18, fontFamily: dialogBodyFont)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(txtDismiss),
            ),
            TextButton(
              onPressed: () async { // کلمه async اضافه شد

                // --- ذخیره نتیجه جدید در حافظه ---
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('last_bmi', bmi.toStringAsFixed(1));

                setState(() {
                  bmiResult = bmi.toStringAsFixed(1);
                  bmiStatus = status;
                  bmiAnalysis = getWeightAdvice(bmi, height, weight, age, selectedGender);

                  // آپدیت متغیر روی صفحه تا بلافاصله به عنوان آخرین نتیجه دیده شود
                  lastBmiResult = bmiResult;

                  if (bmi < 18.5) bmiColor = Colors.blue;
                  else if (bmi < 25) bmiColor = Colors.green;
                  else if (bmi < 30) bmiColor = Colors.orange;
                  else bmiColor = Colors.red;
                });
                Navigator.of(context).pop();
              },
              child: Text(txtAnalyze),
            ),
          ],
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
                  // یک پس‌زمینه محو و زیبا از رنگ اصلی
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  // رنگ متن و آیکون
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // لبه‌های کاملاً گرد
                    side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5), // حاشیه رنگی
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: () {
                  widget.onToggleLanguage();
                  setState(() {
                    bmiResult = ''; // پاک کردن نتیجه هنگام تغییر زبان
                  });
                },
                icon: const Icon(Icons.language, size: 20),
                label: Text(
                  widget.isFarsi ? 'English' : 'فارسی',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      // اگر زبان الان فارسی است، دکمه کلمه English را نشان می‌دهد پس فونت ETimes می‌خواهیم
                      fontFamily: widget.isFarsi ? 'ETimes' : 'BNazanin'
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
              // --- GENDER ROW ---
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

              // --- HEIGHT CARD ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 6)],
                ),
                child: Column(
                  children: [
                    Text(txtHeight, style: const TextStyle(fontSize: 24)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(height.toInt().toString(), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                        Text(txtCm, style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    Slider(
                      value: height,
                      min: 120,
                      max: 240,
                      // فرمول: 240 منهای 120 = 120 (برای پرش‌های دقیق ۱ سانتی‌متری)
                      divisions: 120,
                      activeColor: Theme.of(context).colorScheme.primary,
                      inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      label: '${height.toInt()} cm', // نمایش عدد روی حباب در زمان کشیدن
                      onChanged: (val) => setState(() => height = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // --- WEIGHT & AGE ROW ---
              Row(
                children: [
                  Expanded(
                    child: CounterCard(
                      title: txtWeight,
                      value: weight,
                      unit: widget.isFarsi ? ' کیلو' : ' kg',
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
                      min: 1,
                      max: 120,
                      onChanged: (val) => setState(() => age = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- CALCULATE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: calculateBMI,
                  child: Text(txtCalculate, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              // --- LAST BMI HISTORY ---
              if (lastBmiResult.isNotEmpty && bmiResult.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    widget.isFarsi
                        ? 'آخرین BMI ثبت‌شده شما: $lastBmiResult'
                        : 'Your Last BMI: $lastBmiResult',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.8), // همرنگ دکمه‌ها اما کمی محو
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              // --- RESULT DISPLAY ---
              if (bmiResult.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: bmiColor, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Text('BMI = $bmiResult', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(bmiStatus, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(bmiAnalysis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.5)),
                    ],
                  ),
                ),

              const SizedBox(height: 16), // فضای خالی در انتهای اسکرول
            ],
          ),
        ),
      ),
    );
  }
}

// ================= CUSTOM WIDGETS =================

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
        padding: const EdgeInsets.all(16),
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
              height: 50,
              colorFilter: ColorFilter.mode(isSelected ? Theme.of(context).colorScheme.primary : Colors.white, BlendMode.srcIn),
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white, fontSize: 18)),
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
  final ValueChanged<int> onChanged;

  final int min;
  final int max;

  const CounterCard({super.key, required this.title, required this.value, required this.unit, required this.onChanged,this.min = 1,this.max = 200});

  @override
  State<CounterCard> createState() => _CounterCardState();
}

class _CounterCardState extends State<CounterCard> {
  Timer? _timer;

  void _updateValue(int delta) {
    int newValue = widget.value + delta;

    // شرط اصلاح‌شده: عدد باید بین حداقل و حداکثرِ تعیین‌شده باشد
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 6)],
      ),
      child: Column(
        children: [
          Text(widget.title, style: const TextStyle(fontSize: 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(widget.value.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text(widget.unit, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(Icons.remove, () => _startTimer(-1)),
              _buildControlButton(Icons.add, () => _startTimer(1)),
            ],
          )
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