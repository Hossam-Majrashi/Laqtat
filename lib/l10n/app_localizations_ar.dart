// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'لقطات';

  @override
  String get appDescription =>
      'استخراج لقطات مميزة من أي مقطع فيديو وتجميعها في شبكة صور فائقة الجمال وجاهزة للتصدير.';

  @override
  String get next => 'التالي';

  @override
  String get back => 'السابق';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get selectLanguagePrompt => 'اختر لغة التطبيق المفضلة لديك';

  @override
  String get chooseTheme => 'اختر المظهر';

  @override
  String get selectThemePrompt => 'اختر النمط البصري المفضل لديك';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get projects => 'المشاريع';

  @override
  String get settings => 'الإعدادات';

  @override
  String get newProject => 'مشروع جديد';

  @override
  String get importVideo => 'استيراد فيديو';

  @override
  String get importVideoPrompt => 'اختر ملف فيديو أو اسحبه وأفلته هنا';

  @override
  String get supportedFormats =>
      'الصيغ المدعومة: MP4, MOV, MKV, WebM, AVI, FLV, WMV, TS, RM...';

  @override
  String get regenerate => 'إعادة توليد';

  @override
  String get export => 'تصدير';

  @override
  String get exportImage => 'تصدير الصورة';

  @override
  String get exportPng => 'تصدير PNG';

  @override
  String get exportJpg => 'تصدير JPG';

  @override
  String get exportQuality => 'دقة الشبكة';

  @override
  String get standardQuality => 'قياسية (أسرع)';

  @override
  String get highQuality => 'دقة عالية';

  @override
  String get frameCount => 'عدد اللقطات';

  @override
  String get defaultFrameCount => 'عدد اللقطات الافتراضي';

  @override
  String get defaultExportFormat => 'صيغة التصدير الافتراضية';

  @override
  String get defaultSaveLocation => 'موقع الحفظ الافتراضي';

  @override
  String get systemDefault => 'افتراضي النظام';

  @override
  String get selectFolder => 'تحديد المجلد';

  @override
  String get clearAllData => 'مسح جميع البيانات المحلية';

  @override
  String get clearDataConfirmation =>
      'هل أنت متأكد من حذف جميع المشاريع المحفوظة واستعادة الإعدادات الأصلية؟';

  @override
  String get clearDataSuccess => 'تم مسح جميع البيانات المحلية بنجاح.';

  @override
  String get confirm => 'تأكيد';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get deleteProject => 'حذف المشروع';

  @override
  String get deleteProjectConfirmation => 'هل أنت متأكد من حذف هذا المشروع؟';

  @override
  String get noProjectsTitle => 'لا توجد مشاريع حتى الآن';

  @override
  String get noProjectsSubtitle =>
      'استورد فيديو لتوليد شبكة اللقطات الأولى الخاصة بك';

  @override
  String processingVideo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'جاري استخراج $count لقطة من الفيديو...',
      many: 'جاري استخراج $count لقطة من الفيديو...',
      few: 'جاري استخراج $count لقطات من الفيديو...',
      two: 'جاري استخراج لقطتين من الفيديو...',
      one: 'جاري استخراج لقطة واحدة من الفيديو...',
    );
    return '$_temp0';
  }

  @override
  String get generatingGrid => 'جاري تركيب شبكة اللقطات...';

  @override
  String get exportSuccess => 'تم حفظ الصورة في المعرض بنجاح';

  @override
  String get exportFailed => 'فشل تصدير الصورة.';

  @override
  String get unsupportedVideoFormat =>
      'صيغة الفيديو غير مدعومة. يرجى اختيار ملف فيديو مدعوم.';

  @override
  String get ffmpegNotFound =>
      'أداة ffmpeg غير مثبتة على النظام. يرجى تثبيتها للاستمرار.';

  @override
  String get webStorageNotice =>
      'تنبيه: في نسخة الويب، يتم حفظ المشاريع محلياً داخل متصفحك الحالي فقط.';

  @override
  String get videoDuration => 'المدة';

  @override
  String get dateCreated => 'تاريخ الإنشاء';

  @override
  String get projectDetails => 'تفاصيل المشروع';

  @override
  String framesExtracted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم استخراج $count لقطة',
      many: 'تم استخراج $count لقطة',
      few: 'تم استخراج $count لقطات',
      two: 'تم استخراج لقطتين',
      one: 'تم استخراج لقطة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get aboutApp => 'عن لقطات';

  @override
  String get version => 'الإصدار';

  @override
  String get offlineNote =>
      'خصوصية تامة وبدون إنترنت: لا يغادر الفيديو أو البيانات جهازك أبداً.';

  @override
  String get theme => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get close => 'إغلاق';

  @override
  String get save => 'حفظ';

  @override
  String get copy => 'نسخ';

  @override
  String get errorLoadingVideo =>
      'تعذر قراءة ملف الفيديو. يرجى تجربة فيديو آخر.';

  @override
  String get developer => 'المطور';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get website => 'الموقع الإلكتروني';
}
