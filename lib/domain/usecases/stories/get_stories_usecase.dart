import '../../entities/stories/story_entity.dart';
import '../../repositories/stories_repository.dart';

class GetStoriesUseCase {
  final StoriesRepository _repository;

  const GetStoriesUseCase(this._repository);

  Stream<List<StoryEntity>> call() => _repository.userStories;
}
