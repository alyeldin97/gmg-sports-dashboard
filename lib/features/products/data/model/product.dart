import 'package:equatable/equatable.dart';
import 'product_variant.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String? nameAr;
  final String? description;
  final String? descriptionAr;
  final double price;
  final double? compareAtPrice;
  final List<String> images;
  final int stock;
  final bool isActive;
  final bool isFeatured;
  final List<String> collectionIds;
  final List<ProductVariant> variants;

  const Product({
    this.id = '',
    required this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    this.price = 0,
    this.compareAtPrice,
    this.images = const [],
    this.stock = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.collectionIds = const [],
    this.variants = const [],
  });

  String? get primaryImage => images.isNotEmpty ? images.first : null;

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        nameAr: j['name_ar'] as String?,
        description: j['description'] as String?,
        descriptionAr: j['description_ar'] as String?,
        price: (j['price'] as num?)?.toDouble() ?? 0,
        compareAtPrice: (j['compare_at_price'] as num?)?.toDouble(),
        images: (j['images'] as List<dynamic>?)?.cast<String>() ?? const [],
        stock: j['stock'] as int? ?? 0,
        isActive: j['is_active'] as bool? ?? true,
        isFeatured: j['is_featured'] as bool? ?? false,
        collectionIds: (j['product_collections'] as List<dynamic>? ?? [])
            .map((c) => (c as Map<String, dynamic>)['collection_id'] as String)
            .toList(),
        variants: ((j['product_variants'] as List<dynamic>? ?? [])
            .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder))),
      );

  Map<String, dynamic> toUpsertJson() => {
        if (id.isNotEmpty) 'id': id,
        'name': name,
        'name_ar': nameAr,
        'description': description,
        'description_ar': descriptionAr,
        'price': price,
        'compare_at_price': compareAtPrice,
        'images': images,
        'stock': stock,
        'is_active': isActive,
        'is_featured': isFeatured,
      };

  Product copyWith({
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    double? price,
    double? compareAtPrice,
    List<String>? images,
    int? stock,
    bool? isActive,
    bool? isFeatured,
    List<String>? collectionIds,
    List<ProductVariant>? variants,
  }) =>
      Product(
        id: id,
        name: name ?? this.name,
        nameAr: nameAr ?? this.nameAr,
        description: description ?? this.description,
        descriptionAr: descriptionAr ?? this.descriptionAr,
        price: price ?? this.price,
        compareAtPrice: compareAtPrice ?? this.compareAtPrice,
        images: images ?? this.images,
        stock: stock ?? this.stock,
        isActive: isActive ?? this.isActive,
        isFeatured: isFeatured ?? this.isFeatured,
        collectionIds: collectionIds ?? this.collectionIds,
        variants: variants ?? this.variants,
      );

  @override
  List<Object?> get props => [id, name, price, stock, isActive, isFeatured, variants, collectionIds];
}
