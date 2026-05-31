/// A saved teleprompter script.
class Script {
  final String id;
  String title;
  String body;

  Script({required this.id, required this.title, required this.body});

  factory Script.create() => Script(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: '',
        body: '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
      };

  factory Script.fromJson(Map<String, dynamic> json) => Script(
        id: json['id'] as String,
        title: (json['title'] as String?) ?? '',
        body: (json['body'] as String?) ?? '',
      );
}
