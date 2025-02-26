class PrivacyPolicy {
  final String header;
  final List<PrivacyPolicyBody> body;
  final String footer;
  final String updatedDate;

  PrivacyPolicy({
    required this.header,
    required this.body,
    required this.footer,
    required this.updatedDate,
  });

  factory PrivacyPolicy.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicy(
      header: json['header'] ?? '',
      body: (json['body'] as List<dynamic>?)
              ?.map(
                  (e) => PrivacyPolicyBody.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      footer: json['footer'] ?? '',
      updatedDate: json['updatedDate'] ?? '',
    );
  }
}

class PrivacyPolicyBody {
  final String number;
  final String title;
  final String text;
  final List<PrivacyPolicyList> list;

  PrivacyPolicyBody({
    required this.number,
    required this.title,
    required this.text,
    required this.list,
  });

  factory PrivacyPolicyBody.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyBody(
      number: json['number'] ?? '',
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      list: (json['list'] as List<dynamic>?)
              ?.map(
                  (e) => PrivacyPolicyList.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PrivacyPolicyList {
  final String number;
  final String text;
  final List<String> bullet;

  PrivacyPolicyList({
    required this.number,
    required this.text,
    required this.bullet,
  });

  factory PrivacyPolicyList.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyList(
      number: json['number'] ?? '',
      text: json['text'] ?? '',
      bullet: (json['bullet'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
