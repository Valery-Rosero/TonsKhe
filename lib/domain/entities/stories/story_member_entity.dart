class StoryMemberEntity {
  final String id;
  final String storyId;
  final String userId;
  final DateTime joinedAt;

  const StoryMemberEntity({
    required this.id,
    required this.storyId,
    required this.userId,
    required this.joinedAt,
  });
}
