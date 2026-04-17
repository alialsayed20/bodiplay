class Question {
  const Question({
    required this.id,
    required this.categoryId,
    required this.pointValue,
    required this.text,
    required this.languageCode,
    required this.isActive,
  });

  final String id;
  final String categoryId;
  final int pointValue;
  final String text;
  final String languageCode;
  final bool isActive;

  Question copyWith({
    String? id,
    String? categoryId,
    int? pointValue,
    String? text,
    String? languageCode,
    bool? isActive,
  }) {
    return Question(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      pointValue: pointValue ?? this.pointValue,
      text: text ?? this.text,
      languageCode: languageCode ?? this.languageCode,
      isActive: isActive ?? this.isActive,
    );
  }
}