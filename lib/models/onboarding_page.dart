/// Model class representing a single onboarding page
class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  /// Factory constructor to create OnboardingPage from JSON
  factory OnboardingPage.fromJson(Map<String, dynamic> json) {
    return OnboardingPage(
      title: json['title'] as String,
      description: json['description'] as String,
      imagePath: json['imagePath'] as String,
    );
  }

  /// Convert OnboardingPage to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imagePath': imagePath,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingPage &&
        other.title == title &&
        other.description == description &&
        other.imagePath == imagePath;
  }

  @override
  int get hashCode {
    return title.hashCode ^ description.hashCode ^ imagePath.hashCode;
  }

  @override
  String toString() {
    return 'OnboardingPage(title: $title, description: $description, imagePath: $imagePath)';
  }
}
