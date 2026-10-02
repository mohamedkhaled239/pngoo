// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'محمل ومحرر الفيديو';

  @override
  String get pasteLinkHint => 'الصق رابط الفيديو وسيتم التحميل مباشرة للمعرض';

  @override
  String get urlHint => 'https://www.tiktok.com/...';

  @override
  String get paste => 'لصق';

  @override
  String get downloadVideo => 'تحميل الفيديو';

  @override
  String get enterVideoUrl => 'الرجاء إدخال رابط الفيديو';

  @override
  String get enterValidUrl => 'الرجاء إدخال رابط صحيح';

  @override
  String get status => 'الحالة';

  @override
  String get downloading => 'جاري التحميل';

  @override
  String get fetchingInfo => 'جاري جلب المعلومات';

  @override
  String get saving => 'جاري الحفظ';

  @override
  String get processing => 'قيد المعالجة';

  @override
  String get downloadSuccess => 'تم تحميل الفيديو بنجاح ✓';

  @override
  String get noVideoFound => 'لم يتم العثور على فيديو للتحميل';

  @override
  String get downloadFailed => 'فشل تحميل الفيديو';

  @override
  String get saveFailed => 'فشل حفظ الفيديو في المعرض';

  @override
  String errorOccurred(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get albumName => 'تطبيق تحرير الفيديو';

  String get arabic => 'العربية';
  String get english => 'English';
  String get chooseLanguage => 'اختر اللغة';
  String get cancel => 'إلغاء';
  String languageChangedTo(String language) => 'تم تغيير اللغة إلى $language';
  String get reportProblem => 'الإبلاغ عن مشكلة';
  String get describeProblem => 'صف المشكلة التي تواجهها:';
  String get writeProblemDetails => 'اكتب تفاصيل المشكلة هنا...';
  String get send => 'إرسال';
  String get thankYouForReporting =>
      'شكراً على الإبلاغ! سيتم مراجعة مشكلتك قريباً.';
  String get frequentlyAskedQuestions => 'الأسئلة الشائعة';
  String get howToTrimVideo => 'كيف أقص الفيديو؟';
  String get trimVideoDescription =>
      'اختر فيديو من الصفحة الرئيسية، ثم اضغط على أداة "قص الفيديو"';
  String get howToMergeVideos => 'كيف أدمج فيديوهات متعددة؟';
  String get mergeVideosDescription =>
      'استخدم أداة "دمج الفيديوهات" واختر عدة فيديوهات';
  String get howToSaveVideo => 'كيف أحفظ الفيديو المُعدل؟';
  String get saveVideoDescription => 'بعد التعديل، اضغط على "حفظ في المعرض"';
  String get close => 'إغلاق';
  String get premiumVersion => 'النسخة المميزة';
  String get subscribeToPremium => 'اشترك في النسخة المميزة للحصول على:';
  String get noAds => '✓ بدون إعلانات';
  String get unlimitedVideos => '✓ مقاطع فيديو غير محدودة';
  String get highExportQuality => '✓ جودة تصدير عالية';
  String get advancedTools => '✓ أدوات متقدمة';
  String get price => 'السعر: 9.99 دولار / شهر';
  String get notNow => 'الآن لا';
  String get subscribeNow => 'اشترك الآن';
  String get redirectToAppStore => 'سيتم التوجيه إلى متجر التطبيقات...';
  String get privacyPolicy => 'سياسة الخصوصية';
  String get dataProtection => 'حماية البيانات';
  String get dataProtectionDescription =>
      'نحن نحرص على حماية بيانات مستخدمينا بأعلى مستويات الأمان والتشفير.';
  String get dataUsage => 'استخدام البيانات';
  String get dataUsageDescription =>
      'لا نشارك بيانات المستخدمين مع أطراف ثالثة دون موافقة صريحة.';
  String get temporaryFiles => 'الملفات المؤقتة';
  String get temporaryFilesDescription =>
      'يتم حذف الملفات المؤقتة تلقائياً بعد انتهائك من استخدام التطبيق.';
  String get updates => 'التحديثات';
  String get updatesDescription =>
      'قد نحدث هذه السياسة من وقت لآخر. يرجى مراجعتها بانتظام.';
  String get agree => 'أوافق';
  String get copyrights => 'حقوق النشر';
  String get appCopyright => '© 2025 تطبيق تحرير الفيديو';
  String get allRightsReserved => 'جميع الحقوق محفوظة';
  String get license => 'الترخيص';
  String get licenseDescription =>
      'هذا التطبيق مرخص تحت رخصة MIT. يمكنك استخدامه وفقاً لشروط الرخصة.';
  String get usedLibraries => 'المكتبات المستخدمة';
  String get usedLibrariesDescription =>
      'يستخدم التطبيق عدة مكتبات مفتوحة المصدر. نشكر جميع المساهمين.';
  String get personalUse => 'الاستخدام الشخصي';
  String get personalUseDescription =>
      'يمكنك استخدام هذا التطبيق للأغراض الشخصية والتجارية.';
  String get ok => 'موافق';
  String get contactUs => 'اتصل بنا';
  String get email => 'البريد الإلكتروني';
  String get emailAddress => 'mojz.mna@gmail.com';
  String get phone => 'الهاتف';
  String get phoneNumber => '+966 50 123 4567';
  String get website => 'X';
  String get websiteUrl => 'https://x.com/ln_95n';
  String get settings => 'الإعدادات';
  String get language => 'اللغة';
  String get reportAProblem => 'الإبلاغ عن مشكلة';
  String get faq => 'الأسئلة الشائعة';
  String get purchaseRemoveAds => 'الشراء وإزالة الاعلانات';
  String get privacyPolicyTitle => 'سياسة الخصوصية';
  String get contactUsTitle => 'اتصل بنا';
  String get cannotOpenLink => 'لا يمكن فتح الرابط';
  String get linkCopied => 'رابط منسوخ!';
  String get tapToPaste => 'اضغط للصق الرابط';

  String get downloadVideoNavBar => 'تحميل الفيديو';

  String get editVideoNavBar => 'تعديل الفيديو';
}
