class BugAnalysisResult {
  final String name;
  final String species;
  final String dangerLevel;
  final String description;
  final String habitat;
  final String venomous;
  final String diseases;
  final String safetyTips;

  BugAnalysisResult({
    required this.name,
    required this.species,
    required this.dangerLevel,
    required this.description,
    required this.habitat,
    required this.venomous,
    required this.diseases,
    required this.safetyTips,
  });

  factory BugAnalysisResult.fromJson(Map<String, dynamic> json) {
    return BugAnalysisResult(
      name: json['name'] ?? 'Unknown',
      species: json['species'] ?? 'Unknown',
      dangerLevel: json['dangerLevel'] ?? 'Unknown',
      description: json['description'] ?? '',
      habitat: json['habitat'] ?? '',
      venomous: json['venomous'] ?? 'Unknown',
      diseases: json['diseases'] ?? '',
      safetyTips: json['safetyTips'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'dangerLevel': dangerLevel,
      'description': description,
      'habitat': habitat,
      'venomous': venomous,
      'diseases': diseases,
      'safetyTips': safetyTips,
    };
  }
}
