import '../../entities/stories/story_entity.dart';
import '../../repositories/stories_repository.dart';

class UpdateStoryUseCase {
  final StoriesRepository _repository;

  const UpdateStoryUseCase(this._repository);

  Future<StoryEntity> call({
    required String storyId,
    String? name,
    StoryCoverImage? coverImage,
  }) {
    return _repository.updateStory(storyId: storyId, name: name, coverImage: coverImage);
  }
}
