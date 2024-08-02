import 'dart:convert';

class News {
  final String title;
  final String id;
  final String uploadedAt;
  final List<String> topics;
  final String thumbnail;
  final String url;

  News({
    required this.title,
    required this.id,
    required this.uploadedAt,
    required this.topics,
    required this.thumbnail,
    required this.url,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title'],
      id: json['id'],
      uploadedAt: json['uploadedAt'],
      topics: List<String>.from(json['topics']),
      thumbnail: json['thumbnail'],
      url: json['url'],
    );
  }

  static List<News> fromJsonList(String jsonString) {
    final data = json.decode(jsonString) as List<dynamic>;
    return data.map((item) => News.fromJson(item)).toList();
  }
}
