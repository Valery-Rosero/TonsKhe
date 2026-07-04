// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storiesRepository)
final storiesRepositoryProvider = StoriesRepositoryProvider._();

final class StoriesRepositoryProvider
    extends
        $FunctionalProvider<
          StoriesRepository,
          StoriesRepository,
          StoriesRepository
        >
    with $Provider<StoriesRepository> {
  StoriesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storiesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storiesRepositoryHash();

  @$internal
  @override
  $ProviderElement<StoriesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StoriesRepository create(Ref ref) {
    return storiesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoriesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoriesRepository>(value),
    );
  }
}

String _$storiesRepositoryHash() => r'81088f38b519cc044e8faac1b268b47bf6bb9c4c';

@ProviderFor(createStoryUseCase)
final createStoryUseCaseProvider = CreateStoryUseCaseProvider._();

final class CreateStoryUseCaseProvider
    extends
        $FunctionalProvider<
          CreateStoryUseCase,
          CreateStoryUseCase,
          CreateStoryUseCase
        >
    with $Provider<CreateStoryUseCase> {
  CreateStoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createStoryUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createStoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateStoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateStoryUseCase create(Ref ref) {
    return createStoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateStoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateStoryUseCase>(value),
    );
  }
}

String _$createStoryUseCaseHash() =>
    r'f4b01415173447038405af0e429dc5ae72e7c5f7';

@ProviderFor(joinStoryUseCase)
final joinStoryUseCaseProvider = JoinStoryUseCaseProvider._();

final class JoinStoryUseCaseProvider
    extends
        $FunctionalProvider<
          JoinStoryUseCase,
          JoinStoryUseCase,
          JoinStoryUseCase
        >
    with $Provider<JoinStoryUseCase> {
  JoinStoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'joinStoryUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$joinStoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<JoinStoryUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  JoinStoryUseCase create(Ref ref) {
    return joinStoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JoinStoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JoinStoryUseCase>(value),
    );
  }
}

String _$joinStoryUseCaseHash() => r'59c88d69851de5e8a9a2af039e850f59a4883f6d';

@ProviderFor(updateStoryUseCase)
final updateStoryUseCaseProvider = UpdateStoryUseCaseProvider._();

final class UpdateStoryUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateStoryUseCase,
          UpdateStoryUseCase,
          UpdateStoryUseCase
        >
    with $Provider<UpdateStoryUseCase> {
  UpdateStoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateStoryUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateStoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateStoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateStoryUseCase create(Ref ref) {
    return updateStoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateStoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateStoryUseCase>(value),
    );
  }
}

String _$updateStoryUseCaseHash() =>
    r'b67cabb857e0fd77cb8086c7d971d4344b707478';

@ProviderFor(getStoriesUseCase)
final getStoriesUseCaseProvider = GetStoriesUseCaseProvider._();

final class GetStoriesUseCaseProvider
    extends
        $FunctionalProvider<
          GetStoriesUseCase,
          GetStoriesUseCase,
          GetStoriesUseCase
        >
    with $Provider<GetStoriesUseCase> {
  GetStoriesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getStoriesUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getStoriesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetStoriesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetStoriesUseCase create(Ref ref) {
    return getStoriesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetStoriesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetStoriesUseCase>(value),
    );
  }
}

String _$getStoriesUseCaseHash() => r'e8bf23daeb8238204d95e99d8741b3296de03072';

/// Realtime list of the current user's Historias.

@ProviderFor(StoriesList)
final storiesListProvider = StoriesListProvider._();

/// Realtime list of the current user's Historias.
final class StoriesListProvider
    extends $StreamNotifierProvider<StoriesList, List<StoryEntity>> {
  /// Realtime list of the current user's Historias.
  StoriesListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storiesListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storiesListHash();

  @$internal
  @override
  StoriesList create() => StoriesList();
}

String _$storiesListHash() => r'a7af141081c4ef1bd2a22099e31de7a3fdb7bb48';

/// Realtime list of the current user's Historias.

abstract class _$StoriesList extends $StreamNotifier<List<StoryEntity>> {
  Stream<List<StoryEntity>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<StoryEntity>>, List<StoryEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<StoryEntity>>, List<StoryEntity>>,
              AsyncValue<List<StoryEntity>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
