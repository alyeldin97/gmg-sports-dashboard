import 'package:flutter/material.dart';
import '../styling/colors.dart';
import '../styling/text_styles.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.subtitle, this.onRetry});

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: AppColors.primaryMist, shape: BoxShape.circle),
            child: Icon(icon, size: 40, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 14),
          Text(title, style: AppTextStyles.heading3),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: AppTextStyles.bodySmall),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
