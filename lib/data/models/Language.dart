class LanguageModel {
  final Map<String, String> languages;

  LanguageModel({required this.languages});

  // Factory constructor to create an instance from JSON
  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      languages: Map<String, String>.from(json),
    );
  }

  // Method to convert the instance back to JSON
  Map<String, dynamic> toJson() {
    return languages;
  }
}
