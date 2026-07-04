import '../../../domain/entities/stories/story_member_entity.dart';

class StoryMemberModel extends StoryMemberEntity {
  const StoryMemberModel({
    required super.id,
    required super.storyId,
    required super.userId,
    required super.joinedAt,
  });

  factory StoryMemberModel.fromJson(Map<String, dynamic> json) {
    return StoryMemberModel(
      id: json['id'] as String,
      storyId: json['story_id'] as String,
      userId: json['user_id'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'story_id': storyId,
      'user_id': userId,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
