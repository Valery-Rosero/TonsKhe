import '../../../domain/entities/stories/story_entity.dart';

class StoryModel extends StoryEntity {
  const StoryModel({
    required super.id,
    required super.name,
    super.coverUrl,
    required super.inviteCode,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    required super.memberCount,
  });

  /// Expects a row selected with the embedded aggregate
  /// `select('*, story_members(count)')`.
  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      coverUrl: json['cover_url'] as String?,
      inviteCode: json['invite_code'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      memberCount: _memberCountFrom(json['story_members']),
    );
  }

  static int _memberCountFrom(dynamic field) {
    if (field is List && field.isNotEmpty) {
      final first = field.first;
      if (first is Map && first['count'] != null) {
        return first['count'] as int;
      }
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cover_url': coverUrl,
      'invite_code': inviteCode,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
