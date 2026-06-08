import 'package:equatable/equatable.dart';

class ProductVariant extends Equatable {
  final String id;
  final String name;
  final String? nameAr;
  final double? price;
  final int stock;
  final int sortOrder;

  const ProductVariant({
    this.id = '',
    required this.name,
    this.nameAr,
    this.price,
    this.stock = 0,
    this.sortOrder = 0,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> j) => ProductVariant(
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        nameAr: j['name_ar'] as String?,
        price: (j['price'] as num?)?.toDouble(),
        stock: j['stock'] as int? ?? 0,
        sortOrder: j['sort_order'] as int? ?? 0,
      );

  Map<String, dynamic> toUpsertJson(String productId, int order) => {
        if (id.isNotEmpty) 'id': id,
        'product_id': productId,
        'name': name,
        'name_ar': nameAr,
        'price': price,
        'stock': stock,
        'sort_order': order,
      };

  ProductVariant copyWith({String? name, double? price, int? stock}) => ProductVariant(
        id: id,
        name: name ?? this.name,
        nameAr: nameAr,
        price: price ?? this.price,
        stock: stock ?? this.stock,
        sortOrder: sortOrder,
      );

  @override
  List<Object?> get props => [id, name, price, stock];
}
