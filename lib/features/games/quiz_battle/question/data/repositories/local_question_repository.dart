import '../../domain/models/question.dart';
import '../../domain/repositories/question_repository.dart';

class LocalQuestionRepository implements QuestionRepository {
  const LocalQuestionRepository();

  static const List<Question> _questions = <Question>[
    Question(
      id: 'q_geo_10_ar_1',
      categoryId: 'geography',
      pointValue: 10,
      text: 'ما هي عاصمة المملكة العربية السعودية؟',
      languageCode: 'ar',
      isActive: true,
    ),
    Question(
      id: 'q_geo_25_ar_1',
      categoryId: 'geography',
      pointValue: 25,
      text: 'ما هي أكبر قارة في العالم من حيث المساحة؟',
      languageCode: 'ar',
      isActive: true,
    ),
    Question(
      id: 'q_sci_10_ar_1',
      categoryId: 'science',
      pointValue: 10,
      text: 'ما هو الكوكب الأقرب إلى الشمس؟',
      languageCode: 'ar',
      isActive: true,
    ),
    Question(
      id: 'q_sci_25_ar_1',
      categoryId: 'science',
      pointValue: 25,
      text: 'ما هو الغاز الذي تتنفسه النباتات ليلًا وتستخدمه نهارًا في البناء الضوئي؟',
      languageCode: 'ar',
      isActive: true,
    ),
    Question(
      id: 'q_hist_10_ar_1',
      categoryId: 'history',
      pointValue: 10,
      text: 'في أي قارة تقع مصر؟',
      languageCode: 'ar',
      isActive: true,
    ),
    Question(
      id: 'q_hist_25_ar_1',
      categoryId: 'history',
      pointValue: 25,
      text: 'من هو أول من سافر إلى الفضاء؟',
      languageCode: 'ar',
      isActive: true,
    ),
    Question(
      id: 'q_geo_10_en_1',
      categoryId: 'geography',
      pointValue: 10,
      text: 'What is the capital of Saudi Arabia?',
      languageCode: 'en',
      isActive: true,
    ),
    Question(
      id: 'q_geo_25_en_1',
      categoryId: 'geography',
      pointValue: 25,
      text: 'What is the largest continent by area?',
      languageCode: 'en',
      isActive: true,
    ),
    Question(
      id: 'q_sci_10_en_1',
      categoryId: 'science',
      pointValue: 10,
      text: 'Which planet is closest to the sun?',
      languageCode: 'en',
      isActive: true,
    ),
    Question(
      id: 'q_sci_25_en_1',
      categoryId: 'science',
      pointValue: 25,
      text: 'What gas do plants use in photosynthesis?',
      languageCode: 'en',
      isActive: true,
    ),
    Question(
      id: 'q_hist_10_en_1',
      categoryId: 'history',
      pointValue: 10,
      text: 'On which continent is Egypt located?',
      languageCode: 'en',
      isActive: true,
    ),
    Question(
      id: 'q_hist_25_en_1',
      categoryId: 'history',
      pointValue: 25,
      text: 'Who was the first human to travel to space?',
      languageCode: 'en',
      isActive: true,
    ),
  ];

  @override
  Future<Question?> getQuestionForBoardSelection({
    required String categoryId,
    required int pointValue,
    required String languageCode,
    Set<String> excludedQuestionIds = const <String>{},
  }) async {
    try {
      return _questions.firstWhere(
        (Question question) =>
            question.isActive &&
            question.categoryId == categoryId &&
            question.pointValue == pointValue &&
            question.languageCode == languageCode &&
            !excludedQuestionIds.contains(question.id),
      );
    } catch (_) {
      return null;
    }
  }
}