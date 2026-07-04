import 'dart:typed_data';

import '../entities/stories/story_entity.dart';
import '../entities/stories/story_member_entity.dart';

class StoryCoverImage {
  final Uint8List bytes;
  final String extension;

  const StoryCoverImage({required this.bytes, required this.extension});
}

abstract class StoriesRepository {
  /// Emits the current user's Historias on every change to `stories` or
  /// `story_members`, including the initial load.
  Stream<List<StoryEntity>> get userStories;

  Future<StoryEntity> createStory({required String name, StoryCoverImage? coverImage});

  Future<StoryEntity> joinStory({required String inviteCode});

  Future<StoryEntity> updateStory({
    required String storyId,
    String? name,
    StoryCoverImage? coverImage,
  });

  Future<List<StoryMemberEntity>> getStoryMembers(String storyId);
}
