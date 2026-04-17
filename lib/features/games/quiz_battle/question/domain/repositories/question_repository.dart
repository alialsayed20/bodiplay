import '../models/question.dart';

abstract interface class QuestionRepository {
  Future<Question?> getQuestionForBoardSelection({
    required String categoryId,
    required int pointValue,
    required String languageCode,
    Set<String> excludedQuestionIds = const <String>{},
  });
}