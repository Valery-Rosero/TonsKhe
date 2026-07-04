class StoryEntity {
  final String id;
  final String name;
  final String? coverUrl;
  final String inviteCode;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int memberCount;

  const StoryEntity({
    required this.id,
    required this.name,
    this.coverUrl,
    required this.inviteCode,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.memberCount,
  });
}
