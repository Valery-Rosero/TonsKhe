import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

const String _storyCoversBucket = 'story-covers';

class StoriesRemoteDataSource {
  final SupabaseClient _client;

  const StoriesRemoteDataSource(this._client);

  Future<String> uploadCoverImage({
    required String pathKey,
    required Uint8List bytes,
    required String extension,
  }) async {
    final path = '$pathKey/cover_${DateTime.now().millisecondsSinceEpoch}.$extension';
    await _client.storage.from(_storyCoversBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$extension', upsert: true),
        );
    return _client.storage.from(_storyCoversBucket).getPublicUrl(path);
  }

  /// Calls the `generate-invite-code` Edge Function, which creates the
  /// `stories` row (with a unique invite code) and adds the caller as its
  /// first `story_members` row, all server-side. Returns the new story id.
  Future<String> createStoryViaEdgeFunction({required String name, String? coverUrl}) async {
    final response = await _client.functions.invoke(
      'generate-invite-code',
      body: {'name': name, if (coverUrl != null) 'cover_url': coverUrl},
    );
    return (response.data as Map)['story_id'] as String;
  }

  /// Calls the `join-story` Edge Function, which validates the code, checks
  /// the 2-member limit, and inserts the caller into `story_members`
  /// server-side. Returns the joined story id.
  Future<String> callJoinStory(String inviteCode) async {
    final response = await _client.functions.invoke(
      'join-story',
      body: {'invite_code': inviteCode},
    );
    return (response.data as Map)['story_id'] as String;
  }

  Future<Map<String, dynamic>> getStoryById(String storyId) {
    return _client.from('stories').select('*, story_members(count)').eq('id', storyId).single();
  }

  Future<List<Map<String, dynamic>>> getUserStories() {
    return _client
        .from('stories')
        .select('*, story_members(count)')
        .order('updated_at', ascending: false);
  }

  Future<Map<String, dynamic>> updateStory({
    required String storyId,
    String? name,
    String? coverUrl,
  }) async {
    final updates = <String, dynamic>{'updated_at': DateTime.now().toIso8601String()};
    if (name != null) updates['name'] = name;
    if (coverUrl != null) updates['cover_url'] = coverUrl;

    await _client.from('stories').update(updates).eq('id', storyId);
    return getStoryById(storyId);
  }

  Future<List<Map<String, dynamic>>> getStoryMembers(String storyId) {
    return _client.from('story_members').select().eq('story_id', storyId);
  }

  Stream<List<Map<String, dynamic>>> watchStories() {
    return _client.from('stories').stream(primaryKey: ['id']);
  }

  Stream<List<Map<String, dynamic>>> watchStoryMembers() {
    return _client.from('story_members').stream(primaryKey: ['id']);
  }
}
