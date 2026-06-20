// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'GMG Sports Admin';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Retry';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get create => 'Create';

  @override
  String get search => 'Search';

  @override
  String get somethingWrong => 'Something went wrong';

  @override
  String get requiredField => 'Required';

  @override
  String get currency => 'EGP';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get confirmDelete => 'Delete?';

  @override
  String get deleteMessage => 'This action cannot be undone.';

  @override
  String get signIn => 'Sign in';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get adminLogin => 'Admin login';

  @override
  String get adminLoginSubtitle => 'Sign in to manage your store';

  @override
  String get accessDenied =>
      'Access denied — this account is not an administrator.';

  @override
  String get logout => 'Log out';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navProducts => 'Products';

  @override
  String get navCollections => 'Collections';

  @override
  String get navBanners => 'Banners';

  @override
  String get navOrders => 'Orders';

  @override
  String get navSettings => 'Settings';

  @override
  String get overview => 'Overview';

  @override
  String get totalOrders => 'Total orders';

  @override
  String get pendingOrders => 'Pending orders';

  @override
  String get revenue => 'Revenue';

  @override
  String get totalProducts => 'Products';

  @override
  String get recentOrders => 'Recent orders';

  @override
  String get name => 'Name';

  @override
  String get nameAr => 'Name (Arabic)';

  @override
  String get title => 'Title';

  @override
  String get titleAr => 'Title (Arabic)';

  @override
  String get description => 'Description';

  @override
  String get descriptionAr => 'Description (Arabic)';

  @override
  String get price => 'Price';

  @override
  String get compareAtPrice => 'Compare-at price';

  @override
  String get stock => 'Stock';

  @override
  String get featured => 'Featured';

  @override
  String get imageUrls => 'Image URLs (one per line)';

  @override
  String get imageUrl => 'Image URL';

  @override
  String get sortOrder => 'Sort order';

  @override
  String get variants => 'Variants';

  @override
  String get addVariant => 'Add variant';

  @override
  String get variantName => 'Variant name';

  @override
  String get collectionsLabel => 'Collections';

  @override
  String get noProducts => 'No products yet';

  @override
  String get newProduct => 'New product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get noCollections => 'No collections yet';

  @override
  String get newCollection => 'New collection';

  @override
  String get editCollection => 'Edit collection';

  @override
  String get noBanners => 'No banners yet';

  @override
  String get newBanner => 'New banner';

  @override
  String get editBanner => 'Edit banner';

  @override
  String get linkType => 'Link type';

  @override
  String get linkNone => 'None';

  @override
  String get linkCollection => 'Collection';

  @override
  String get linkProduct => 'Product';

  @override
  String get linkTargetId => 'Target ID';

  @override
  String get customerOrders => 'Customer orders';

  @override
  String get noOrders => 'No orders yet';

  @override
  String get orderDetails => 'Order details';

  @override
  String orderNumber(Object id) {
    return 'Order #$id';
  }

  @override
  String get updateStatus => 'Update status';

  @override
  String get recipient => 'Recipient';

  @override
  String get deliveryAddress => 'Delivery address';

  @override
  String get deliveryDate => 'Delivery date';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get cod => 'Cash on delivery';

  @override
  String get instapay => 'InstaPay on delivery';

  @override
  String get items => 'Items';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get deliveryFee => 'Delivery fee';

  @override
  String get discount => 'Discount';

  @override
  String get total => 'Total';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusOutForDelivery => 'Out for delivery';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get freeDeliveryThreshold => 'Free delivery threshold';

  @override
  String get instapayHandle => 'InstaPay handle';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get navShipping => 'Shipping';

  @override
  String get activate => 'Activate';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get confirmStr => 'Confirm';

  @override
  String get allFilter => 'All';

  @override
  String get newestFirst => 'Newest first';

  @override
  String get oldestFirst => 'Oldest first';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get orderNotes => 'Order notes';

  @override
  String get statusUpdated => 'Status updated';

  @override
  String get failedToUpdateStatus => 'Failed to update status';

  @override
  String get bannerDeleted => 'Banner deleted';

  @override
  String get failedToDelete => 'Failed to delete';

  @override
  String get collectionDeleted => 'Collection deleted';

  @override
  String linkedProductsWarning(Object count) {
    return '$count linked products will be unlinked.';
  }

  @override
  String get deletedSuccessfully => 'Deleted successfully';

  @override
  String get failedToUpdate => 'Failed to update';

  @override
  String get productDeleted => 'Product deleted';

  @override
  String get productUpdated => 'Product updated';

  @override
  String get productDuplicated => 'Product duplicated';

  @override
  String get duplicateProduct => 'Duplicate';

  @override
  String get productsDeleted => 'Products deleted';

  @override
  String get productsActivated => 'Products activated';

  @override
  String get productsDeactivated => 'Products deactivated';

  @override
  String selectedCount(Object count) {
    return '$count selected';
  }

  @override
  String get governoratesTitle => 'Shipping zones';

  @override
  String get noGovernorates => 'No shipping zones yet';

  @override
  String get newGovernorate => 'New zone';

  @override
  String get editGovernorate => 'Edit zone';

  @override
  String get shippingCostLabel => 'Shipping cost (EGP)';

  @override
  String get deliveryDays => 'Delivery days';

  @override
  String get navDiscounts => 'Discounts';

  @override
  String get discountsTitle => 'Discount Codes';

  @override
  String get noCoupons => 'No coupons yet';

  @override
  String get newCoupon => 'New coupon';

  @override
  String get editCoupon => 'Edit coupon';

  @override
  String get couponCodeLabel => 'Coupon code';

  @override
  String get discountType => 'Discount type';

  @override
  String get discountValueLabel => 'Value';

  @override
  String get minOrderAmountLabel => 'Min. order (optional)';

  @override
  String get maxUsesLabel => 'Max uses (optional)';

  @override
  String get expiryDateLabel => 'Expiry date';

  @override
  String get generateCode => 'Generate';

  @override
  String get percentageType => 'Percentage (%)';

  @override
  String get fixedType => 'Fixed (EGP)';

  @override
  String get usedCount => 'Used';

  @override
  String get couponCreated => 'Coupon created';

  @override
  String get couponUpdated => 'Coupon updated';

  @override
  String get couponDeleted => 'Coupon deleted';

  @override
  String get noExpiry => 'No expiry';

  @override
  String get storeSettings => 'Store settings';

  @override
  String get accountSettings => 'Account';

  @override
  String get adminEmail => 'Admin email';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get integrations => 'Integrations';

  @override
  String get metaPixelId => 'Meta Pixel ID';

  @override
  String get metaPixelIdHint => 'e.g. 1234567890123456';

  @override
  String get metaPixelIdDesc =>
      'Enter your Meta (Facebook) Pixel ID to track ad conversions. Leave empty to disable.';

  @override
  String get freeShippingRule => 'Free shipping rule';

  @override
  String get freeShippingThreshold => 'Min. order for free shipping (EGP)';

  @override
  String freeShippingThresholdValue(Object amount) {
    return 'Free shipping on orders over $amount EGP';
  }

  @override
  String get disabled => 'Disabled';

  @override
  String get couponCodes => 'Coupon codes';

  @override
  String get productImages => 'Product images';

  @override
  String get uploadImages => 'Upload images';

  @override
  String get uploading => 'Uploading…';

  @override
  String get monthRevenue => 'This Month Revenue';

  @override
  String get lowStockAlert => 'Low Stock Alert';

  @override
  String get topProducts => 'Top Products';

  @override
  String get salesTrend => 'Sales Trend (Last 7 Days)';

  @override
  String get ordersByStatus => 'Orders by Status';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get addProduct => 'Add Product';

  @override
  String get addCoupon => 'Add Coupon';

  @override
  String stockLeft(Object count) {
    return '$count left';
  }

  @override
  String get noLowStock => 'All products are well-stocked';

  @override
  String get viewAll => 'View all';

  @override
  String get customer => 'Customer';

  @override
  String get noData => 'No data yet';

  @override
  String get dropImagesHere => 'Drop images here or click to upload';

  @override
  String get invalidImageType =>
      'Invalid file type. Allowed: jpg, jpeg, png, webp, gif';

  @override
  String get imageTooLarge => 'Image is too large (max 5MB)';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get analyticsTitle => 'Sales Analytics';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get thisMonth => 'This Month';

  @override
  String get customRange => 'Custom Range';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get avgOrderValue => 'Avg. Order Value';

  @override
  String get uniqueCustomers => 'Customers';

  @override
  String get revenueTrend => 'Revenue Trend';

  @override
  String get vsLastPeriod => 'vs previous period';

  @override
  String get noAnalyticsData => 'No data for this period';

  @override
  String get selectDateRange => 'Select date range';

  @override
  String get stockMovements => 'Stock History';

  @override
  String get adjustStock => 'Adjust Stock';

  @override
  String get quantityChange => 'Quantity change';

  @override
  String get reason => 'Reason';

  @override
  String get restock => 'Restock';

  @override
  String get manualAdjustment => 'Adjustment';

  @override
  String get damageOrLoss => 'Damage / Loss';

  @override
  String get returnReason => 'Return';

  @override
  String get stockAdjusted => 'Stock adjusted';

  @override
  String get notes => 'Notes';

  @override
  String get currentStock => 'Current stock';

  @override
  String get unitsSold => 'Units sold';

  @override
  String get noStockHistory => 'No stock movements yet';
}
