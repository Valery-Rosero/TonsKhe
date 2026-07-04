import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/stories/story_entity.dart';
import '../../providers/stories/active_story_provider.dart';
import '../../widgets/common/loading_widget.dart';

class StoryDetailPage extends ConsumerWidget {
  const StoryDetailPage({super.key, required this.storyId, required this.tabIndex});

  final String storyId;
  final int tabIndex;

  static const _tabs = ['Categorías', 'Historial', 'Álbum', 'Ruleta'];
  static const _tabIcons = [
    Icons.category_outlined,
    Icons.history,
    Icons.photo_library_outlined,
    Icons.casino_outlined,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final story = ref.watch(activeStoryProvider(storyId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: story == null
            ? const Center(child: AppLoadingIndicator())
            : Column(
                children: [
                  _Header(story: story),
                  Expanded(child: _TabPlaceholder(label: _tabs[tabIndex])),
                ],
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primaryAccent,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: tabIndex,
        onTap: (index) => _goToTab(context, index),
        items: List.generate(_tabs.length, (index) {
          return BottomNavigationBarItem(icon: Icon(_tabIcons[index]), label: _tabs[index]);
        }),
      ),
    );
  }

  void _goToTab(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.storyCategories(storyId));
      case 1:
        context.go(AppRoutes.storyHistory(storyId));
      case 2:
        context.go(AppRoutes.storyAlbum(storyId));
      case 3:
        context.go(AppRoutes.storyRoulette(storyId));
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.story});

  final StoryEntity story;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 160,
          width: double.infinity,
          child: story.coverUrl == null
              ? const ColoredBox(
                  color: AppColors.surface,
                  child: Icon(Icons.favorite, color: AppColors.primaryAccent, size: 40),
                )
              : CachedNetworkImage(imageUrl: story.coverUrl!, fit: BoxFit.cover),
        ),
        Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, AppColors.background.withValues(alpha: 0.9)],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 16,
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),
              Expanded(
                child: Text(
                  story.name,
                  style: AppTextStyles.heading(fontSize: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label — próximamente',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
      ),
    );
  }
}
