class ChatGroup {
  const ChatGroup({
    required this.id,
    required this.name,
    required this.subtitle,
    this.type = "organization",
  });

  final String id;
  final String name;
  final String subtitle;
  final String type;

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      id: json["id"] as String,
      name: json["name"] as String,
      subtitle: json["subtitle"] as String? ?? json["type"] as String? ?? "",
      type: json["type"] as String? ?? "organization",
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.createdAt,
    this.mine = false,
  });

  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String body;
  final DateTime createdAt;
  final bool mine;

  factory ChatMessage.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final senderId = json["senderId"] as String? ?? json["authorUserId"] as String? ?? "";
    return ChatMessage(
      id: json["id"] as String,
      groupId: json["groupId"] as String? ?? "",
      senderId: senderId,
      senderName: json["senderName"] as String? ?? json["authorName"] as String? ?? "Member",
      body: json["content"] as String? ?? json["body"] as String? ?? "",
      createdAt: DateTime.parse(
        (json["createdAt"] as String?) ?? DateTime.now().toIso8601String(),
      ).toLocal(),
      mine: currentUserId != null && senderId == currentUserId,
    );
  }
}
