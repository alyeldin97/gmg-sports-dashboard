import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../data/model/collection.dart';
import '../cubits/collections_cubit.dart';
import 'collection_form_screen.dart';

class CollectionsMgmtScreen extends StatelessWidget {
  const CollectionsMgmtScreen({super.key});

  void _openForm(BuildContext context, {Collection? collection}) {
    final cubit = context.read<CollectionsCubit>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: CollectionFormDialog(collection: collection),
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
              Text(context.l10n.navCollections, style: AppTextStyles.heading1),
              const Spacer(),
              AppButton(label: context.l10n.newCollection, icon: Icons.add, onPressed: () => _openForm(context)),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<CollectionsCubit, CollectionsState>(
              builder: (context, state) {
                if (state.status == CollectionsStatus.loading || state.status == CollectionsStatus.initial) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
                }
                if (state.collections.isEmpty) {
                  return EmptyState(icon: Icons.grid_view_outlined, title: context.l10n.noCollections);
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: state.collections.length,
                  itemBuilder: (context, i) {
                    final c = state.collections[i];
                    return Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: AppNetworkImage(url: c.imageUrl)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(child: Text(c.title, style: AppTextStyles.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis)),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  onPressed: () => _openForm(context, collection: c),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                  onPressed: () => context.read<CollectionsCubit>().delete(c.id),
                                ),
                              ],
                            ),
                          ),
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
