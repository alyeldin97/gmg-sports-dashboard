import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../data/model/banner_item.dart';
import '../cubits/banners_cubit.dart';
import 'banner_form_screen.dart';

class BannersMgmtScreen extends StatelessWidget {
  const BannersMgmtScreen({super.key});

  void _openForm(BuildContext context, {BannerItem? banner}) {
    final cubit = context.read<BannersCubit>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(value: cubit, child: BannerFormDialog(banner: banner)),
    );
  }

  void _confirmDelete(BuildContext context, BannerItem b) {
    final cubit = context.read<BannersCubit>();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(context.l10n.confirmDelete),
        content: Text(context.l10n.deleteMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(context.l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final ok = await cubit.delete(b.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? context.l10n.bannerDeleted : context.l10n.failedToDelete),
                ));
              }
            },
            child: Text(context.l10n.delete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(context.l10n.navBanners, style: AppTextStyles.heading1),
              const Spacer(),
              AppButton(label: context.l10n.newBanner, icon: Icons.add, onPressed: () => _openForm(context)),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<BannersCubit, BannersState>(
              builder: (context, state) {
                if ((state.status == BannersStatus.loading || state.status == BannersStatus.initial) && state.banners.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
                }
                if (state.status == BannersStatus.failure && state.banners.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.l10n.somethingWrong, style: AppTextStyles.body),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.read<BannersCubit>().load(),
                          child: Text(context.l10n.retry),
                        ),
                      ],
                    ),
                  );
                }
                if (state.banners.isEmpty) {
                  return EmptyState(icon: Icons.image_outlined, title: context.l10n.noBanners);
                }
                return ListView.separated(
                  itemCount: state.banners.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final b = state.banners[i];
                    return Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          AppNetworkImage(url: b.imageUrl, width: 160, height: 80),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.title ?? '—', style: AppTextStyles.subtitle),
                                Text('${context.l10n.linkType}: ${b.linkType}', style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                          if (!b.isActive)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(context.l10n.inactive,
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight)),
                            ),
                          IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _openForm(context, banner: b)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            onPressed: () => _confirmDelete(context, b),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
