// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_story_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Historia currently open in [story_detail_page], derived reactively
/// from [storiesListProvider] so realtime updates (name/cover changes made
/// by the other member) are reflected without a separate fetch.

@ProviderFor(activeStory)
final activeStoryProvider = ActiveStoryFamily._();

/// The Historia currently open in [story_detail_page], derived reactively
/// from [storiesListProvider] so realtime updates (name/cover changes made
/// by the other member) are reflected without a separate fetch.

final class ActiveStoryProvider
    extends $FunctionalProvider<StoryEntity?, StoryEntity?, StoryEntity?>
    with $Provider<StoryEntity?> {
  /// The Historia currently open in [story_detail_page], derived reactively
  /// from [storiesListProvider] so realtime updates (name/cover changes made
  /// by the other member) are reflected without a separate fetch.
  ActiveStoryProvider._({
    required ActiveStoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeStoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeStoryHash();

  @override
  String toString() {
    return r'activeStoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<StoryEntity?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StoryEntity? create(Ref ref) {
    final argument = this.argument as String;
    return activeStory(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoryEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoryEntity?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveStoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeStoryHash() => r'bb502d226215328e3b4e44480fc32c02b8b6d7a8';

/// The Historia currently open in [story_detail_page], derived reactively
/// from [storiesListProvider] so realtime updates (name/cover changes made
/// by the other member) are reflected without a separate fetch.

final class ActiveStoryFamily extends $Family
    with $FunctionalFamilyOverride<StoryEntity?, String> {
  ActiveStoryFamily._()
    : super(
        retry: null,
        name: r'activeStoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The Historia currently open in [story_detail_page], derived reactively
  /// from [storiesListProvider] so realtime updates (name/cover changes made
  /// by the other member) are reflected without a separate fetch.

  ActiveStoryProvider call(String storyId) =>
      ActiveStoryProvider._(argument: storyId, from: this);

  @override
  String toString() => r'activeStoryProvider';
}
