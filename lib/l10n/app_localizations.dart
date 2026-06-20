import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'GMG Sports Admin'**
  String get appName;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @somethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWrong;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get currency;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get confirmDelete;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteMessage;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @adminLogin.
  ///
  /// In en, this message translates to:
  /// **'Admin login'**
  String get adminLogin;

  /// No description provided for @adminLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your store'**
  String get adminLoginSubtitle;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access denied — this account is not an administrator.'**
  String get accessDenied;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get navCollections;

  /// No description provided for @navBanners.
  ///
  /// In en, this message translates to:
  /// **'Banners'**
  String get navBanners;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total orders'**
  String get totalOrders;

  /// No description provided for @pendingOrders.
  ///
  /// In en, this message translates to:
  /// **'Pending orders'**
  String get pendingOrders;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @totalProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get totalProducts;

  /// No description provided for @recentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent orders'**
  String get recentOrders;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameAr.
  ///
  /// In en, this message translates to:
  /// **'Name (Arabic)'**
  String get nameAr;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @titleAr.
  ///
  /// In en, this message translates to:
  /// **'Title (Arabic)'**
  String get titleAr;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionAr.
  ///
  /// In en, this message translates to:
  /// **'Description (Arabic)'**
  String get descriptionAr;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @compareAtPrice.
  ///
  /// In en, this message translates to:
  /// **'Compare-at price'**
  String get compareAtPrice;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @imageUrls.
  ///
  /// In en, this message translates to:
  /// **'Image URLs (one per line)'**
  String get imageUrls;

  /// No description provided for @imageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrl;

  /// No description provided for @sortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort order'**
  String get sortOrder;

  /// No description provided for @variants.
  ///
  /// In en, this message translates to:
  /// **'Variants'**
  String get variants;

  /// No description provided for @addVariant.
  ///
  /// In en, this message translates to:
  /// **'Add variant'**
  String get addVariant;

  /// No description provided for @variantName.
  ///
  /// In en, this message translates to:
  /// **'Variant name'**
  String get variantName;

  /// No description provided for @collectionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collectionsLabel;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProducts;

  /// No description provided for @newProduct.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get newProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @noCollections.
  ///
  /// In en, this message translates to:
  /// **'No collections yet'**
  String get noCollections;

  /// No description provided for @newCollection.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get newCollection;

  /// No description provided for @editCollection.
  ///
  /// In en, this message translates to:
  /// **'Edit collection'**
  String get editCollection;

  /// No description provided for @noBanners.
  ///
  /// In en, this message translates to:
  /// **'No banners yet'**
  String get noBanners;

  /// No description provided for @newBanner.
  ///
  /// In en, this message translates to:
  /// **'New banner'**
  String get newBanner;

  /// No description provided for @editBanner.
  ///
  /// In en, this message translates to:
  /// **'Edit banner'**
  String get editBanner;

  /// No description provided for @linkType.
  ///
  /// In en, this message translates to:
  /// **'Link type'**
  String get linkType;

  /// No description provided for @linkNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get linkNone;

  /// No description provided for @linkCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get linkCollection;

  /// No description provided for @linkProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get linkProduct;

  /// No description provided for @linkTargetId.
  ///
  /// In en, this message translates to:
  /// **'Target ID'**
  String get linkTargetId;

  /// No description provided for @customerOrders.
  ///
  /// In en, this message translates to:
  /// **'Customer orders'**
  String get customerOrders;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrders;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetails;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderNumber(Object id);

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update status'**
  String get updateStatus;

  /// No description provided for @recipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get recipient;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get deliveryAddress;

  /// No description provided for @deliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Delivery date'**
  String get deliveryDate;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @cod.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get cod;

  /// No description provided for @instapay.
  ///
  /// In en, this message translates to:
  /// **'InstaPay on delivery'**
  String get instapay;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFee;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get statusOutForDelivery;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @freeDeliveryThreshold.
  ///
  /// In en, this message translates to:
  /// **'Free delivery threshold'**
  String get freeDeliveryThreshold;

  /// No description provided for @instapayHandle.
  ///
  /// In en, this message translates to:
  /// **'InstaPay handle'**
  String get instapayHandle;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @navShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get navShipping;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @confirmStr.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmStr;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get oldestFirst;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @orderNotes.
  ///
  /// In en, this message translates to:
  /// **'Order notes'**
  String get orderNotes;

  /// No description provided for @statusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Status updated'**
  String get statusUpdated;

  /// No description provided for @failedToUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update status'**
  String get failedToUpdateStatus;

  /// No description provided for @bannerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Banner deleted'**
  String get bannerDeleted;

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete'**
  String get failedToDelete;

  /// No description provided for @collectionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Collection deleted'**
  String get collectionDeleted;

  /// No description provided for @linkedProductsWarning.
  ///
  /// In en, this message translates to:
  /// **'{count} linked products will be unlinked.'**
  String linkedProductsWarning(Object count);

  /// No description provided for @deletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deletedSuccessfully;

  /// No description provided for @failedToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Failed to update'**
  String get failedToUpdate;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get productDeleted;

  /// No description provided for @productUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product updated'**
  String get productUpdated;

  /// No description provided for @productDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Product duplicated'**
  String get productDuplicated;

  /// No description provided for @duplicateProduct.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicateProduct;

  /// No description provided for @productsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Products deleted'**
  String get productsDeleted;

  /// No description provided for @productsActivated.
  ///
  /// In en, this message translates to:
  /// **'Products activated'**
  String get productsActivated;

  /// No description provided for @productsDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Products deactivated'**
  String get productsDeactivated;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(Object count);

  /// No description provided for @governoratesTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipping zones'**
  String get governoratesTitle;

  /// No description provided for @noGovernorates.
  ///
  /// In en, this message translates to:
  /// **'No shipping zones yet'**
  String get noGovernorates;

  /// No description provided for @newGovernorate.
  ///
  /// In en, this message translates to:
  /// **'New zone'**
  String get newGovernorate;

  /// No description provided for @editGovernorate.
  ///
  /// In en, this message translates to:
  /// **'Edit zone'**
  String get editGovernorate;

  /// No description provided for @shippingCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping cost (EGP)'**
  String get shippingCostLabel;

  /// No description provided for @deliveryDays.
  ///
  /// In en, this message translates to:
  /// **'Delivery days'**
  String get deliveryDays;

  /// No description provided for @navDiscounts.
  ///
  /// In en, this message translates to:
  /// **'Discounts'**
  String get navDiscounts;

  /// No description provided for @discountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Discount Codes'**
  String get discountsTitle;

  /// No description provided for @noCoupons.
  ///
  /// In en, this message translates to:
  /// **'No coupons yet'**
  String get noCoupons;

  /// No description provided for @newCoupon.
  ///
  /// In en, this message translates to:
  /// **'New coupon'**
  String get newCoupon;

  /// No description provided for @editCoupon.
  ///
  /// In en, this message translates to:
  /// **'Edit coupon'**
  String get editCoupon;

  /// No description provided for @couponCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Coupon code'**
  String get couponCodeLabel;

  /// No description provided for @discountType.
  ///
  /// In en, this message translates to:
  /// **'Discount type'**
  String get discountType;

  /// No description provided for @discountValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get discountValueLabel;

  /// No description provided for @minOrderAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Min. order (optional)'**
  String get minOrderAmountLabel;

  /// No description provided for @maxUsesLabel.
  ///
  /// In en, this message translates to:
  /// **'Max uses (optional)'**
  String get maxUsesLabel;

  /// No description provided for @expiryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get expiryDateLabel;

  /// No description provided for @generateCode.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generateCode;

  /// No description provided for @percentageType.
  ///
  /// In en, this message translates to:
  /// **'Percentage (%)'**
  String get percentageType;

  /// No description provided for @fixedType.
  ///
  /// In en, this message translates to:
  /// **'Fixed (EGP)'**
  String get fixedType;

  /// No description provided for @usedCount.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get usedCount;

  /// No description provided for @couponCreated.
  ///
  /// In en, this message translates to:
  /// **'Coupon created'**
  String get couponCreated;

  /// No description provided for @couponUpdated.
  ///
  /// In en, this message translates to:
  /// **'Coupon updated'**
  String get couponUpdated;

  /// No description provided for @couponDeleted.
  ///
  /// In en, this message translates to:
  /// **'Coupon deleted'**
  String get couponDeleted;

  /// No description provided for @noExpiry.
  ///
  /// In en, this message translates to:
  /// **'No expiry'**
  String get noExpiry;

  /// No description provided for @storeSettings.
  ///
  /// In en, this message translates to:
  /// **'Store settings'**
  String get storeSettings;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSettings;

  /// No description provided for @adminEmail.
  ///
  /// In en, this message translates to:
  /// **'Admin email'**
  String get adminEmail;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @integrations.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get integrations;

  /// No description provided for @metaPixelId.
  ///
  /// In en, this message translates to:
  /// **'Meta Pixel ID'**
  String get metaPixelId;

  /// No description provided for @metaPixelIdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1234567890123456'**
  String get metaPixelIdHint;

  /// No description provided for @metaPixelIdDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your Meta (Facebook) Pixel ID to track ad conversions. Leave empty to disable.'**
  String get metaPixelIdDesc;

  /// No description provided for @freeShippingRule.
  ///
  /// In en, this message translates to:
  /// **'Free shipping rule'**
  String get freeShippingRule;

  /// No description provided for @freeShippingThreshold.
  ///
  /// In en, this message translates to:
  /// **'Min. order for free shipping (EGP)'**
  String get freeShippingThreshold;

  /// No description provided for @freeShippingThresholdValue.
  ///
  /// In en, this message translates to:
  /// **'Free shipping on orders over {amount} EGP'**
  String freeShippingThresholdValue(Object amount);

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @couponCodes.
  ///
  /// In en, this message translates to:
  /// **'Coupon codes'**
  String get couponCodes;

  /// No description provided for @productImages.
  ///
  /// In en, this message translates to:
  /// **'Product images'**
  String get productImages;

  /// No description provided for @uploadImages.
  ///
  /// In en, this message translates to:
  /// **'Upload images'**
  String get uploadImages;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get uploading;

  /// No description provided for @monthRevenue.
  ///
  /// In en, this message translates to:
  /// **'This Month Revenue'**
  String get monthRevenue;

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert'**
  String get lowStockAlert;

  /// No description provided for @topProducts.
  ///
  /// In en, this message translates to:
  /// **'Top Products'**
  String get topProducts;

  /// No description provided for @salesTrend.
  ///
  /// In en, this message translates to:
  /// **'Sales Trend (Last 7 Days)'**
  String get salesTrend;

  /// No description provided for @ordersByStatus.
  ///
  /// In en, this message translates to:
  /// **'Orders by Status'**
  String get ordersByStatus;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @addCoupon.
  ///
  /// In en, this message translates to:
  /// **'Add Coupon'**
  String get addCoupon;

  /// No description provided for @stockLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String stockLeft(Object count);

  /// No description provided for @noLowStock.
  ///
  /// In en, this message translates to:
  /// **'All products are well-stocked'**
  String get noLowStock;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noData;

  /// No description provided for @dropImagesHere.
  ///
  /// In en, this message translates to:
  /// **'Drop images here or click to upload'**
  String get dropImagesHere;

  /// No description provided for @invalidImageType.
  ///
  /// In en, this message translates to:
  /// **'Invalid file type. Allowed: jpg, jpeg, png, webp, gif'**
  String get invalidImageType;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image is too large (max 5MB)'**
  String get imageTooLarge;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales Analytics'**
  String get analyticsTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @avgOrderValue.
  ///
  /// In en, this message translates to:
  /// **'Avg. Order Value'**
  String get avgOrderValue;

  /// No description provided for @uniqueCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get uniqueCustomers;

  /// No description provided for @revenueTrend.
  ///
  /// In en, this message translates to:
  /// **'Revenue Trend'**
  String get revenueTrend;

  /// No description provided for @vsLastPeriod.
  ///
  /// In en, this message translates to:
  /// **'vs previous period'**
  String get vsLastPeriod;

  /// No description provided for @noAnalyticsData.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get noAnalyticsData;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select date range'**
  String get selectDateRange;

  /// No description provided for @stockMovements.
  ///
  /// In en, this message translates to:
  /// **'Stock History'**
  String get stockMovements;

  /// No description provided for @adjustStock.
  ///
  /// In en, this message translates to:
  /// **'Adjust Stock'**
  String get adjustStock;

  /// No description provided for @quantityChange.
  ///
  /// In en, this message translates to:
  /// **'Quantity change'**
  String get quantityChange;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @restock.
  ///
  /// In en, this message translates to:
  /// **'Restock'**
  String get restock;

  /// No description provided for @manualAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get manualAdjustment;

  /// No description provided for @damageOrLoss.
  ///
  /// In en, this message translates to:
  /// **'Damage / Loss'**
  String get damageOrLoss;

  /// No description provided for @returnReason.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnReason;

  /// No description provided for @stockAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Stock adjusted'**
  String get stockAdjusted;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @currentStock.
  ///
  /// In en, this message translates to:
  /// **'Current stock'**
  String get currentStock;

  /// No description provided for @unitsSold.
  ///
  /// In en, this message translates to:
  /// **'Units sold'**
  String get unitsSold;

  /// No description provided for @noStockHistory.
  ///
  /// In en, this message translates to:
  /// **'No stock movements yet'**
  String get noStockHistory;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
