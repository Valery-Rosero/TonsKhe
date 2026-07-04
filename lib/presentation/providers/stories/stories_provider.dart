import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/supabase_config.dart';
import '../../../data/datasources/stories/stories_remote_datasource.dart';
import '../../../data/repositories/stories_repository_impl.dart';
import '../../../domain/entities/stories/story_entity.dart';
import '../../../domain/repositories/stories_repository.dart';
import '../../../domain/usecases/stories/create_story_usecase.dart';
import '../../../domain/usecases/stories/get_stories_usecase.dart';
import '../../../domain/usecases/stories/join_story_usecase.dart';
import '../../../domain/usecases/stories/update_story_usecase.dart';

part 'stories_provider.g.dart';

@Riverpod(keepAlive: true)
StoriesRepository storiesRepository(Ref ref) {
  return StoriesRepositoryImpl(StoriesRemoteDataSource(SupabaseConfig.client));
}

@Riverpod(keepAlive: true)
CreateStoryUseCase createStoryUseCase(Ref ref) {
  return CreateStoryUseCase(ref.watch(storiesRepositoryProvider));
}

@Riverpod(keepAlive: true)
JoinStoryUseCase joinStoryUseCase(Ref ref) {
  return JoinStoryUseCase(ref.watch(storiesRepositoryProvider));
}

@Riverpod(keepAlive: true)
UpdateStoryUseCase updateStoryUseCase(Ref ref) {
  return UpdateStoryUseCase(ref.watch(storiesRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetStoriesUseCase getStoriesUseCase(Ref ref) {
  return GetStoriesUseCase(ref.watch(storiesRepositoryProvider));
}

/// Realtime list of the current user's Historias.
@Riverpod(keepAlive: true)
class StoriesList extends _$StoriesList {
  @override
  Stream<List<StoryEntity>> build() {
    return ref.watch(getStoriesUseCaseProvider).call();
  }
}
