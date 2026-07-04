import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/stories/story_entity.dart';
import 'stories_provider.dart';

part 'active_story_provider.g.dart';

/// The Historia currently open in [story_detail_page], derived reactively
/// from [storiesListProvider] so realtime updates (name/cover changes made
/// by the other member) are reflected without a separate fetch.
@riverpod
StoryEntity? activeStory(Ref ref, String storyId) {
  final stories = ref.watch(storiesListProvider).value ?? const [];
  for (final story in stories) {
    if (story.id == storyId) return story;
  }
  return null;
}
