import 'package:equatable/equatable.dart';

class BannerItem extends Equatable {
  final String id;
  final String? title;
  final String imageUrl;
  final String linkType; // none | collection | product
  final String? linkId;
  final int sortOrder;
  final bool isActive;

  const BannerItem({
    this.id = '',
    this.title,
    required this.imageUrl,
    this.linkType = 'none',
    this.linkId,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory BannerItem.fromJson(Map<String, dynamic> j) => BannerItem(
        id: j['id'] as String? ?? '',
        title: j['title'] as String?,
        imageUrl: j['image_url'] as String? ?? '',
        linkType: j['link_type'] as String? ?? 'none',
        linkId: j['link_id'] as String?,
        sortOrder: j['sort_order'] as int? ?? 0,
        isActive: j['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toUpsertJson() => {
        if (id.isNotEmpty) 'id': id,
        'title': title,
        'image_url': imageUrl,
        'link_type': linkType,
        'link_id': (linkId != null && linkId!.isNotEmpty) ? linkId : null,
        'sort_order': sortOrder,
        'is_active': isActive,
      };

  @override
  List<Object?> get props => [id, imageUrl, linkType, linkId, sortOrder, isActive];
}
