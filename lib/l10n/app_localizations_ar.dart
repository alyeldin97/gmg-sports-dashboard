// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'لوحة تحكم جي إم جي';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get create => 'إنشاء';

  @override
  String get search => 'بحث';

  @override
  String get somethingWrong => 'حدث خطأ ما';

  @override
  String get requiredField => 'مطلوب';

  @override
  String get currency => 'ج.م';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get confirmDelete => 'حذف؟';

  @override
  String get deleteMessage => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get adminLogin => 'دخول المسؤول';

  @override
  String get adminLoginSubtitle => 'سجّل الدخول لإدارة متجرك';

  @override
  String get accessDenied => 'تم الرفض — هذا الحساب ليس مسؤولاً.';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get navDashboard => 'الرئيسية';

  @override
  String get navProducts => 'المنتجات';

  @override
  String get navCollections => 'المجموعات';

  @override
  String get navBanners => 'اللافتات';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get totalOrders => 'إجمالي الطلبات';

  @override
  String get pendingOrders => 'طلبات قيد الانتظار';

  @override
  String get revenue => 'الإيرادات';

  @override
  String get totalProducts => 'المنتجات';

  @override
  String get recentOrders => 'أحدث الطلبات';

  @override
  String get name => 'الاسم';

  @override
  String get nameAr => 'الاسم (عربي)';

  @override
  String get title => 'العنوان';

  @override
  String get titleAr => 'العنوان (عربي)';

  @override
  String get description => 'الوصف';

  @override
  String get descriptionAr => 'الوصف (عربي)';

  @override
  String get price => 'السعر';

  @override
  String get compareAtPrice => 'السعر قبل الخصم';

  @override
  String get stock => 'المخزون';

  @override
  String get featured => 'مميز';

  @override
  String get imageUrls => 'روابط الصور (رابط بكل سطر)';

  @override
  String get imageUrl => 'رابط الصورة';

  @override
  String get sortOrder => 'الترتيب';

  @override
  String get variants => 'المتغيرات';

  @override
  String get addVariant => 'إضافة متغير';

  @override
  String get variantName => 'اسم المتغير';

  @override
  String get collectionsLabel => 'المجموعات';

  @override
  String get noProducts => 'لا توجد منتجات بعد';

  @override
  String get newProduct => 'منتج جديد';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get noCollections => 'لا توجد مجموعات بعد';

  @override
  String get newCollection => 'مجموعة جديدة';

  @override
  String get editCollection => 'تعديل المجموعة';

  @override
  String get noBanners => 'لا توجد لافتات بعد';

  @override
  String get newBanner => 'لافتة جديدة';

  @override
  String get editBanner => 'تعديل اللافتة';

  @override
  String get linkType => 'نوع الرابط';

  @override
  String get linkNone => 'بدون';

  @override
  String get linkCollection => 'مجموعة';

  @override
  String get linkProduct => 'منتج';

  @override
  String get linkTargetId => 'معرّف الهدف';

  @override
  String get customerOrders => 'طلبات العملاء';

  @override
  String get noOrders => 'لا توجد طلبات بعد';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String orderNumber(Object id) {
    return 'طلب رقم #$id';
  }

  @override
  String get updateStatus => 'تحديث الحالة';

  @override
  String get recipient => 'المستلم';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get deliveryDate => 'تاريخ التوصيل';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get cod => 'الدفع عند الاستلام';

  @override
  String get instapay => 'إنستاباي عند الاستلام';

  @override
  String get items => 'العناصر';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get discount => 'خصم';

  @override
  String get total => 'الإجمالي';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusConfirmed => 'مؤكد';

  @override
  String get statusProcessing => 'قيد التجهيز';

  @override
  String get statusOutForDelivery => 'في الطريق';

  @override
  String get statusDelivered => 'تم التوصيل';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String get freeDeliveryThreshold => 'حد التوصيل المجاني';

  @override
  String get instapayHandle => 'معرّف إنستاباي';

  @override
  String get settingsSaved => 'تم حفظ الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get navShipping => 'الشحن';

  @override
  String get activate => 'تفعيل';

  @override
  String get deactivate => 'إلغاء التفعيل';

  @override
  String get confirmStr => 'تأكيد';

  @override
  String get allFilter => 'الكل';

  @override
  String get newestFirst => 'الأحدث أولاً';

  @override
  String get oldestFirst => 'الأقدم أولاً';

  @override
  String get exportCsv => 'تصدير CSV';

  @override
  String get orderNotes => 'ملاحظات الطلب';

  @override
  String get statusUpdated => 'تم تحديث الحالة';

  @override
  String get failedToUpdateStatus => 'فشل تحديث الحالة';

  @override
  String get bannerDeleted => 'تم حذف اللافتة';

  @override
  String get failedToDelete => 'فشل الحذف';

  @override
  String get collectionDeleted => 'تم حذف المجموعة';

  @override
  String linkedProductsWarning(Object count) {
    return 'سيتم إلغاء ربط $count منتج.';
  }

  @override
  String get deletedSuccessfully => 'تم الحذف بنجاح';

  @override
  String get failedToUpdate => 'فشل التحديث';

  @override
  String get productDeleted => 'تم حذف المنتج';

  @override
  String get productUpdated => 'تم تحديث المنتج';

  @override
  String get productDuplicated => 'تم تكرار المنتج';

  @override
  String get duplicateProduct => 'تكرار';

  @override
  String get productsDeleted => 'تم حذف المنتجات';

  @override
  String get productsActivated => 'تم تفعيل المنتجات';

  @override
  String get productsDeactivated => 'تم إلغاء تفعيل المنتجات';

  @override
  String selectedCount(Object count) {
    return 'تم اختيار $count';
  }

  @override
  String get governoratesTitle => 'مناطق الشحن';

  @override
  String get noGovernorates => 'لا توجد مناطق شحن بعد';

  @override
  String get newGovernorate => 'منطقة جديدة';

  @override
  String get editGovernorate => 'تعديل المنطقة';

  @override
  String get shippingCostLabel => 'تكلفة الشحن (ج.م)';

  @override
  String get deliveryDays => 'أيام التوصيل';

  @override
  String get navDiscounts => 'الخصومات';

  @override
  String get discountsTitle => 'أكواد الخصم';

  @override
  String get noCoupons => 'لا توجد كوبونات بعد';

  @override
  String get newCoupon => 'كوبون جديد';

  @override
  String get editCoupon => 'تعديل الكوبون';

  @override
  String get couponCodeLabel => 'كود الخصم';

  @override
  String get discountType => 'نوع الخصم';

  @override
  String get discountValueLabel => 'القيمة';

  @override
  String get minOrderAmountLabel => 'حد أدنى للطلب (اختياري)';

  @override
  String get maxUsesLabel => 'أقصى استخدام (اختياري)';

  @override
  String get expiryDateLabel => 'تاريخ الانتهاء';

  @override
  String get generateCode => 'توليد';

  @override
  String get percentageType => 'نسبة مئوية (%)';

  @override
  String get fixedType => 'مبلغ ثابت (ج.م)';

  @override
  String get usedCount => 'الاستخدام';

  @override
  String get couponCreated => 'تم إنشاء الكوبون';

  @override
  String get couponUpdated => 'تم تحديث الكوبون';

  @override
  String get couponDeleted => 'تم حذف الكوبون';

  @override
  String get noExpiry => 'بدون انتهاء';

  @override
  String get storeSettings => 'إعدادات المتجر';

  @override
  String get accountSettings => 'الحساب';

  @override
  String get adminEmail => 'البريد الإلكتروني للمسؤول';
}
