import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../styling/colors.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({super.key, required this.url, this.width, this.height, this.fit = BoxFit.cover});

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _fallback();
    return CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => Container(width: width, height: height, color: AppColors.primaryMist),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() => Container(
        width: width,
        height: height,
        color: AppColors.primaryMist,
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, color: AppColors.textLight),
      );
}
