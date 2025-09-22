class AgentModel {
  final String id;
  final String userId;
  final String status;
  final List<String> regions;
  final List<String> skills;
  final String? bio;
  final double ratingAvg;
  final int ratingCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  AgentModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.regions,
    required this.skills,
    this.bio,
    required this.ratingAvg,
    required this.ratingCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      status: json['status'] ?? 'pending',
      regions: List<String>.from(json['regions'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      bio: json['bio'],
      ratingAvg: (json['rating_avg'] ?? 0).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'regions': regions,
      'skills': skills,
      'bio': bio,
      'rating_avg': ratingAvg,
      'rating_count': ratingCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AgentModel copyWith({
    String? id,
    String? userId,
    String? status,
    List<String>? regions,
    List<String>? skills,
    String? bio,
    double? ratingAvg,
    int? ratingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      regions: regions ?? this.regions,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
}