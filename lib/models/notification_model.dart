class NotificationModel {
  final int id;
  final int userId;
  final String message;
  final String type;
  final int? relatedId;
  final bool isRead;
  final DateTime createdAt;
  final String timeAgo;
  final String? leadName;
  final String? leadPhone;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.type,
    this.relatedId,
    required this.isRead,
    required this.createdAt,
    required this.timeAgo,
    this.leadName,
    this.leadPhone,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: int.parse(json['id'].toString()),
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      relatedId: json['related_id'] != null
          ? int.tryParse(json['related_id'].toString())
          : (json['lead_id'] != null
                ? int.tryParse(json['lead_id'].toString())
                : null),
      isRead: (json['is_read'].toString() == '1' || json['is_read'] == true),
      createdAt: DateTime.parse(json['created_at']),
      timeAgo: json['time_ago'] ?? '',
      leadName: json['lead_name']?.toString(),
      leadPhone: (json['lead_phone'] ?? json['phone'])?.toString(),
    );
  }
}
