import '../../entities/stories/story_entity.dart';
import '../../repositories/stories_repository.dart';

class JoinStoryUseCase {
  final StoriesRepository _repository;

  const JoinStoryUseCase(this._repository);

  Future<StoryEntity> call({required String inviteCode}) {
    return _repository.joinStory(inviteCode: inviteCode);
  }
}
