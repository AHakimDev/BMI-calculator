import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main (){
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String male = 'male';
  static const String female = 'female';
  String selectedGender = male;
  double sliderValue = 172;
  int weight = 62;
  int age = 27;

  String bmiResult = '';
  String bmiStatus = '';
  Color bmiColor = Colors.transparent;
  String bmiAnalysis = '';

  String getWeightAdvice(double bmi, double heightCm, int weight, int age, String gender) {

    double heightM = heightCm / 100;
    double minHealthy = 18.5 * (heightM * heightM);
    double maxHealthy = 24.9 * (heightM * heightM);

    // هشدار سنی زیر ۲۰
    if (age < 20) {
      return 'BMI standard ranges are designed for adults. For ages under 20, please consult a pediatrician for accurate assessment.';
    }

    // سالمندان ۶۰ به بالا
    if (age >= 60) {
      maxHealthy = 27.0 * (heightM * heightM);
      if (bmi >= 18.5 && bmi <= 27) {
        return 'For adults over 60, a BMI up to 27 is generally considered acceptable. You are within a healthy range.';
      }
    }

    // کمبود وزن
    if (bmi < 18.5) {
      double gain = minHealthy - weight;
      if (gender == 'female') {
        return 'You need to gain ${gain.toStringAsFixed(1)} kg to reach a healthy BMI. Women naturally have higher body fat needs — focus on nutrient-rich foods.';
      }
      return 'You need to gain ${gain.toStringAsFixed(1)} kg to reach a healthy BMI. Focus on strength training and protein-rich nutrition.';
    }

    // اضافه وزن
    if (bmi > 24.9) {
      double lose = weight - maxHealthy;
      if (gender == 'female') {
        return 'You need to lose ${lose.toStringAsFixed(1)} kg to reach a healthy BMI. A combination of cardio and balanced diet is recommended.';
      }
      return 'You need to lose ${lose.toStringAsFixed(1)} kg to reach a healthy BMI. Strength training combined with a caloric deficit is effective.';
    }

    return 'You are within the healthy BMI range. Keep up your balanced lifestyle!';
  }

  String getBmiStatus(double bmi) {
    if (bmi < 18.5) return 'under weight';
    if (bmi < 25) return 'healthy weight';
    if (bmi < 30) return 'over weight';
    return 'obese';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: Color.fromRGBO(100,100,100,1),
              appBar: AppBar(
                title: Text('BMI CALCULATER',
                  style: TextStyle(color: Colors.white, fontFamily: 'ETimes', fontSize: 25),),
                centerTitle: true,
                backgroundColor: Color.fromRGBO(58, 53, 53, 1),
                elevation: 5,
              ),
              body: SafeArea(
                child: Column(
                  children: [

                    // 🔵 کل صفحه اسکرول‌پذیر
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [

                            // ================= ROW 1 (GENDER) =================
                            Row(
                              children: [
                                Flexible(
                                  fit: FlexFit.tight,
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(35, 32, 32, 1),
                                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromRGBO(88, 88, 88, 0.9),
                                          offset: Offset(2, 2),
                                          blurRadius: 8,
                                        )
                                      ],
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedGender = 'male';
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/male.svg',
                                            width: 42,
                                            colorFilter: ColorFilter.mode(
                                              selectedGender == 'male'
                                                  ? Colors.redAccent
                                                  : Colors.white,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          Text(
                                            'male',
                                            style: TextStyle(
                                              color: selectedGender == 'male'
                                                  ? Colors.redAccent
                                                  : Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                Flexible(
                                  fit: FlexFit.tight,
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(35, 32, 32, 1),
                                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromRGBO(88, 88, 88, 0.9),
                                          offset: Offset(2, 2),
                                          blurRadius: 8,
                                        )
                                      ],
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedGender = 'female';
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/woman.svg',
                                            width: 30,
                                            colorFilter: ColorFilter.mode(
                                              selectedGender == 'female'
                                                  ? Colors.redAccent
                                                  : Colors.white,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          Text(
                                            'female',
                                            style: TextStyle(
                                              color: selectedGender == 'female'
                                                  ? Colors.redAccent
                                                  : Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // ================= HEIGHT =================
                            Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(35, 32, 32, 1),
                                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(88, 88, 88, 0.9),
                                    offset: Offset(2, 2),
                                    blurRadius: 8,
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Height',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'ETimes',
                                      fontSize: 26,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        sliderValue.toInt().toString(),
                                        style: const TextStyle(
                                          fontFamily: 'ETimes',
                                          color: Colors.white,
                                          fontSize: 26,
                                        ),
                                      ),
                                      const Text(
                                        ' CM',
                                        style: TextStyle(color: Colors.white, fontSize: 20,fontFamily: 'ETimes'),
                                      ),
                                    ],
                                  ),
                                  CupertinoSlider(
                                    value: sliderValue,
                                    min: 120,
                                    max: 240,
                                    activeColor: Colors.redAccent,
                                    divisions: 120,
                                    onChanged: (c) {
                                      setState(() {
                                        sliderValue = c;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // ================= ROW 3 (WEIGHT + AGE) =================
                            Row(
                              children: [

                                Flexible(
                                  fit: FlexFit.tight,
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(35, 32, 32, 1),
                                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromRGBO(88, 88, 88, 0.9),
                                          offset: Offset(2, 2),
                                          blurRadius: 8,
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        const Text('Weight',
                                            style: TextStyle(color: Colors.white, fontSize: 24,fontFamily: 'ETimes')),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(weight.toString(),
                                                style: const TextStyle(
                                                    color: Colors.white, fontSize: 24,fontFamily: 'ETimes')),
                                            const Text(
                                              ' KG',
                                              style: TextStyle(color: Colors.white, fontSize: 20,fontFamily: 'ETimes'),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            FloatingActionButton(
                                              heroTag: 'w+',
                                              mini: true,
                                              backgroundColor: Colors.white70,
                                              onPressed: () {
                                                setState(() => weight++);
                                              },
                                              child: const Icon(Icons.add),
                                            ),
                                            FloatingActionButton(
                                              heroTag: 'w-',
                                              mini: true,
                                              backgroundColor: Colors.white70,
                                              onPressed: () {
                                                setState(() {
                                                  if (weight > 1) weight--;
                                                });
                                              },
                                              child: const Icon(Icons.remove),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),

                                Flexible(
                                  fit: FlexFit.tight,
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(35, 32, 32, 1),
                                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromRGBO(88, 88, 88, 0.9),
                                          offset: Offset(2, 2),
                                          blurRadius: 8,
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        const Text('Age',
                                            style: TextStyle(color: Colors.white,fontFamily: 'ETimes',fontSize: 24)),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(age.toString(),
                                                style: const TextStyle(
                                                    color: Colors.white, fontSize: 24,fontFamily: 'ETimes')),
                                            const Text(
                                              ' Years',
                                              style: TextStyle(color: Colors.white, fontSize: 20,fontFamily: 'ETimes'),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            FloatingActionButton(
                                              heroTag: 'a+',
                                              mini: true,
                                              backgroundColor: Colors.white70,
                                              onPressed: () {
                                                setState(() => age++);
                                              },
                                              child: const Icon(Icons.add),
                                            ),
                                            FloatingActionButton(
                                              heroTag: 'a-',
                                              mini: true,
                                              backgroundColor: Colors.white70,
                                              onPressed: () {
                                                setState(() {
                                                  if (age > 1) age--;
                                                });
                                              },
                                              child: const Icon(Icons.remove),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            // ================= CALCULATE (UNCHANGED) =================
                            SizedBox(
                              width: double.infinity,
                              height: 70,
                              child: MaterialButton(
                                color: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onPressed: () {

                                  double heightInMeter = sliderValue / 100;
                                  double bmi = weight / (heightInMeter * heightInMeter);

                                  String status = getBmiStatus(bmi);

                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: const Text('Your status is ...', style: TextStyle(fontSize: 18,fontFamily: 'ETimes'),),
                                      content: Text(
                                        'BMI = ${bmi.toStringAsFixed(1)}\n$status', style: TextStyle(fontSize: 18, fontFamily: 'ETimes'),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Dismiss'),
                                        ),
                                        TextButton(
                                          onPressed: () {

                                            setState(() {

                                              bmiResult = bmi.toStringAsFixed(1);
                                              bmiStatus = status;
                                              bmiAnalysis = getWeightAdvice(bmi, sliderValue, weight, age, selectedGender);

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
                                          child: const Text('Analyze'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Calculate',
                                  style: TextStyle(
                                    fontFamily: 'ETimes',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (bmiResult.isNotEmpty)
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 200,
                                ),
                                child: SingleChildScrollView(
                                  child: Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: bmiColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'BMI = $bmiResult',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'ETimes'
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          bmiStatus,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          bmiAnalysis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),


                  ],
                ),
              ),
            );
          }
      ),
    );
  }
}
