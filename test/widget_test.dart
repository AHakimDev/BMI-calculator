import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// نکته: اگر نام پوشه پروژه شما چیزی غیر از bmi است، آن را در خط زیر اصلاح کنید
import 'package:bmi/main.dart';

void main() {
  testWidgets('تست عملکرد اصلی اپلیکیشن BMI', (WidgetTester tester) async {

    // ۱. اجرای مجازی اپلیکیشن شما
    await tester.pumpWidget(const BMICalculatorApp());

    // ۲. بررسی لود شدن زبان پیش‌فرض (انگلیسی)
    expect(find.text('BMI CALCULATOR'), findsOneWidget);
    expect(find.text('Weight'), findsOneWidget);

    // ۳. بررسی مقادیر پیش‌فرض
    // انتظار داریم وزن روی 70 و سن روی 25 باشد
    expect(find.text('70'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);

    // ۴. شبیه‌سازی افزایش وزن
    // چون در صفحه دو دکمه '+' داریم (یکی برای وزن و یکی برای سن)،
    // ربات با دستور .first اولین دکمه که مربوط به وزن است را پیدا کرده و لمس می‌کند.
    await tester.tap(find.byIcon(Icons.add).first);

    // رفرش صفحه برای اعمال تغییرات وضعیت (State)
    await tester.pump();

    // ۵. بررسی اینکه وزن از 70 به 71 تغییر کرده باشد
    expect(find.text('70'), findsNothing);
    expect(find.text('71'), findsOneWidget);

    // ۶. شبیه‌سازی محاسبه و باز شدن دیالوگ
    await tester.tap(find.text('Calculate'));

    // 💡 نکته مهم: چون باز شدن دیالوگ (پاپ‌آپ) دارای انیمیشن است،
    // از دستور pumpAndSettle استفاده می‌کنیم تا ربات صبر کند انیمیشن کاملاً تمام شود.
    await tester.pumpAndSettle();

    // ۷. بررسی باز شدن پنجره دیالوگ
    // ربات بررسی می‌کند که آیا تیتر دیالوگ و دکمه‌های آن روی صفحه ظاهر شده‌اند یا خیر
    expect(find.text('Your status is'), findsOneWidget);
    expect(find.text('Analyze'), findsOneWidget);

    // ۸. شبیه‌سازی بستن دیالوگ
    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle(); // صبر برای پایان انیمیشنِ بسته شدن

    // ۹. اطمینان از بسته شدن دیالوگ
    expect(find.text('Your status is'), findsNothing);
  });
}