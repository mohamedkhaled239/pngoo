import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_downloud_app/models/app_config.dart';
import 'package:video_downloud_app/widgets/studio_brand.dart';

void main() {
  testWidgets('studio brand and primary action render correctly', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'Cairo'),
        home: Scaffold(
          body: Column(
            children: [
              const StudioBrand(),
              MintButton(
                label: 'تحليل وتنزيل الفيديو',
                icon: Icons.download,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('يومي'), findsOneWidget);
    expect(find.text('استوديو الفيديو'), findsOneWidget);
    expect(find.text('تنزيل الفيديو'), findsOneWidget);
    expect(find.byIcon(Icons.download), findsOneWidget);
  });

  test('Firestore settings shown in the console are parsed correctly', () {
    final config = AppConfig.fromFirestore({
      'enableAds': true,
      'enableVideoDownload': true,
      'rapidApiBaseUrl': 'https://auto-download-all-in-one.p.rapidapi.com',
      'rapidApiHost': 'auto-download-all-in-one.p.rapidapi.com',
      'rapidApiKey': 'test-key',
      'productionmode': false,
    });

    expect(config.enableAds, isTrue);
    expect(config.enableVideoDownload, isTrue);
    expect(config.rapidApiKey, 'test-key');
    expect(config.enableVideoEdit, isTrue);
    expect(config.productionMode, isFalse);
  });
}
