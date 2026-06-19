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
}
