/// Task model matching the Dispatch Service API.
///
/// Status flow: pending → assigned → accepted → in_progress → completed / cancelled
class Task {
  final String id;
  final String needId;
  final String volunteerId;
  final String? organizationId;
  final String status; // "pending"|"assigned"|"accepted"|"in_progress"|"completed"|"cancelled"
  final String assignmentType; // "auto"|"manual"
  final String? outcome; // "success"|"partial"|"failed"
  final String? feedback;
  final DateTime assignedAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  // Denormalized fields for display (may come from joined data)
  final String? needTitle;
  final String? volunteerName;

  Task({
    required this.id,
    required this.needId,
    required this.volunteerId,
    this.organizationId,
    required this.status,
    this.assignmentType = 'manual',
    this.outcome,
    this.feedback,
    required this.assignedAt,
    this.acceptedAt,
    this.completedAt,
    this.needTitle,
    this.volunteerName,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      needId: json['needId'] ?? '',
      volunteerId: json['volunteerId'] ?? '',
      organizationId: json['organizationId'],
      status: json['status'] ?? 'pending',
      assignmentType: json['assignmentType'] ?? 'manual',
      outcome: json['outcome'],
      feedback: json['feedback'],
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'])
          : DateTime.now(),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      needTitle: json['needTitle'],
      volunteerName: json['volunteerName'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'needId': needId,
        'volunteerId': volunteerId,
        'organizationId': organizationId,
        'status': status,
        'assignmentType': assignmentType,
        'outcome': outcome,
        'feedback': feedback,
        'assignedAt': assignedAt.toIso8601String(),
        'acceptedAt': acceptedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  bool get isActive =>
      status == 'assigned' || status == 'accepted' || status == 'in_progress';

  bool get isCompleted => status == 'completed';

  bool get isCancelled => status == 'cancelled';

  Task copyWith({
    String? status,
    String? outcome,
    String? feedback,
    DateTime? acceptedAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id,
      needId: needId,
      volunteerId: volunteerId,
      organizationId: organizationId,
      status: status ?? this.status,
      assignmentType: assignmentType,
      outcome: outcome ?? this.outcome,
      feedback: feedback ?? this.feedback,
      assignedAt: assignedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      needTitle: needTitle,
      volunteerName: volunteerName,
    );
  }
}
