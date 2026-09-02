class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    this.authorName,
    this.publishedAt,
  });

  final String id;
  final String title;
  final String body;
  final String? authorName;
  final DateTime? publishedAt;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json["id"] as String,
      title: json["title"] as String,
      body: json["body"] as String? ?? "",
      authorName: json["authorName"] as String?,
      publishedAt: json["publishedAt"] == null
          ? null
          : DateTime.parse(json["publishedAt"] as String).toLocal(),
    );
  }
}
