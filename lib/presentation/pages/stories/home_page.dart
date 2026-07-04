import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/stories/stories_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/stories/story_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storiesListProvider);
    final username = ref.watch(authProvider).value?.username;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: storiesAsync.when(
            loading: () => const Center(child: AppLoadingIndicator()),
            error: (error, _) => const Center(
              child: Text(
                'No fue posible cargar tus Historias.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            data: (stories) => CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: _Header(username: username, storyCount: stories.length, ref: ref),
                  ),
                ),
                if (stories.isEmpty)
                  const SliverFillRemaining(hasScrollBody: false, child: _EmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    sliver: SliverList.separated(
                      itemCount: stories.length + 1,
                      separatorBuilder: (context, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == stories.length) {
                          return _JoinStoryCta(onTap: () => context.push(AppRoutes.joinStory));
                        }
                        final story = stories[index];
                        return StoryCard(
                          story: story,
                          onTap: () => context.go(AppRoutes.storyCategories(story.id)),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.textPrimary,
        elevation: 8,
        onPressed: () => context.push(AppRoutes.createStory),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.username, required this.storyCount, required this.ref});

  final String? username;
  final int storyCount;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final initial = (username?.isNotEmpty ?? false) ? username![0].toUpperCase() : '?';
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.primaryAccent, shape: BoxShape.circle),
          child: Text(initial, style: AppTextStyles.heading(fontSize: 16, color: Colors.white)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hola, ${username ?? ''}', style: AppTextStyles.heading(fontSize: 18)),
              const SizedBox(height: 2),
              Text(
                storyCount == 1 ? '1 historia activa' : '$storyCount historias activas',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Cerrar sesión',
          icon: const Icon(Icons.logout, color: AppColors.textSecondary),
          onPressed: () async {
            try {
              await ref.read(signOutUseCaseProvider).call();
            } catch (_) {
              // Session state changes drive navigation; nothing else to do here.
            }
          },
        ),
      ],
    );
  }
}

class _JoinStoryCta extends StatelessWidget {
  const _JoinStoryCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondaryAccent, width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          '¿Tienes un código? Unirse a una Historia',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.secondaryAccent, fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 14,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(color: AppColors.secondaryAccent, shape: BoxShape.circle),
                    ),
                  ),
                  Positioned(
                    right: 14,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(color: AppColors.primaryAccent, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Vuestra próxima aventura\nempieza aquí',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              '¡Crea una Historia o únete a una con un código para empezar a compartir planes, salidas y recuerdos!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.createStory),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text('Crear primera Historia', style: AppTextStyles.heading(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
