import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/stories/story_entity.dart';
import '../../domain/entities/stories/story_member_entity.dart';
import '../../domain/repositories/stories_repository.dart';
import '../datasources/stories/stories_remote_datasource.dart';
import '../models/stories/story_member_model.dart';
import '../models/stories/story_model.dart';

class StoriesRepositoryImpl implements StoriesRepository {
  final StoriesRemoteDataSource _remoteDataSource;

  const StoriesRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<StoryEntity>> get userStories {
    late final StreamController<List<StoryEntity>> controller;
    StreamSubscription? storiesSub;
    StreamSubscription? membersSub;

    Future<void> emitLatest() async {
      try {
        final rows = await _remoteDataSource.getUserStories();
        controller.add(rows.map(StoryModel.fromJson).toList());
      } catch (error) {
        controller.addError(_mapError(error));
      }
    }

    controller = StreamController<List<StoryEntity>>.broadcast(
      onListen: () {
        emitLatest();
        storiesSub = _remoteDataSource.watchStories().listen((_) => emitLatest());
        membersSub = _remoteDataSource.watchStoryMembers().listen((_) => emitLatest());
      },
      onCancel: () async {
        await storiesSub?.cancel();
        await membersSub?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  Future<StoryEntity> createStory({required String name, StoryCoverImage? coverImage}) {
    return _runStories(() async {
      String? coverUrl;
      if (coverImage != null) {
        coverUrl = await _remoteDataSource.uploadCoverImage(
          pathKey: const Uuid().v4(),
          bytes: coverImage.bytes,
          extension: coverImage.extension,
        );
      }

      // The `generate-invite-code` Edge Function creates the story row and
      // the creator's `story_members` entry server-side in one call.
      final storyId = await _remoteDataSource.createStoryViaEdgeFunction(
        name: name,
        coverUrl: coverUrl,
      );

      final hydrated = await _remoteDataSource.getStoryById(storyId);
      return StoryModel.fromJson(hydrated);
    });
  }

  @override
  Future<StoryEntity> joinStory({required String inviteCode}) {
    return _runStories(() async {
      final storyId = await _remoteDataSource.callJoinStory(inviteCode.trim().toUpperCase());
      final hydrated = await _remoteDataSource.getStoryById(storyId);
      return StoryModel.fromJson(hydrated);
    });
  }

  @override
  Future<StoryEntity> updateStory({
    required String storyId,
    String? name,
    StoryCoverImage? coverImage,
  }) {
    return _runStories(() async {
      String? coverUrl;
      if (coverImage != null) {
        coverUrl = await _remoteDataSource.uploadCoverImage(
          pathKey: storyId,
          bytes: coverImage.bytes,
          extension: coverImage.extension,
        );
      }

      final hydrated = await _remoteDataSource.updateStory(
        storyId: storyId,
        name: name,
        coverUrl: coverUrl,
      );
      return StoryModel.fromJson(hydrated);
    });
  }

  @override
  Future<List<StoryMemberEntity>> getStoryMembers(String storyId) {
    return _runStories(() async {
      final rows = await _remoteDataSource.getStoryMembers(storyId);
      return rows.map(StoryMemberModel.fromJson).toList();
    });
  }

  Future<T> _runStories<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } catch (error) {
      throw _mapError(error);
    }
  }

  AppException _mapError(Object error) {
    if (error is FunctionException) {
      final details = error.details;
      if (details is Map && details['error'] is String) {
        return AppException(details['error'] as String);
      }
      return const AppException('No fue posible completar la operación. Intenta de nuevo.');
    }
    if (error is PostgrestException) {
      if (error.code == '23505') {
        return const AppException('Ya existe un registro con esos datos.');
      }
      return const AppException('No fue posible completar la operación. Intenta de nuevo.');
    }
    if (error is StorageException) {
      return const AppException('No fue posible subir la imagen. Intenta de nuevo.');
    }
    return const AppException('Ocurrió un error inesperado. Intenta de nuevo.');
  }
}
