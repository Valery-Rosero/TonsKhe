import '../../entities/stories/story_entity.dart';
import '../../repositories/stories_repository.dart';

class CreateStoryUseCase {
  final StoriesRepository _repository;

  const CreateStoryUseCase(this._repository);

  Future<StoryEntity> call({required String name, StoryCoverImage? coverImage}) {
    return _repository.createStory(name: name, coverImage: coverImage);
  }
}
