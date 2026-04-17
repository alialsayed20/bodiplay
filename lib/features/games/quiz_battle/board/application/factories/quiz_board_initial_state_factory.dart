import '../../domain/enums/board_cell_status.dart';
import '../../domain/models/board_category_column.dart';
import '../../domain/models/board_cell.dart';
import '../../domain/models/board_state.dart';

class QuizBoardInitialStateFactory {
  const QuizBoardInitialStateFactory();

  BoardState create({
    required List<QuizBoardCategorySeed> categories,
    List<int> pointValues = const <int>[10, 25, 50, 100],
  }) {
    final List<BoardCategoryColumn> columns = categories.map(
      (QuizBoardCategorySeed category) {
        final List<BoardCell> cells = pointValues.map((int pointValue) {
          return BoardCell(
            id: '${category.id}_$pointValue',
            categoryId: category.id,
            pointValue: pointValue,
            status: BoardCellStatus.available,
          );
        }).toList();

        return BoardCategoryColumn(
          categoryId: category.id,
          title: category.title,
          cells: cells,
        );
      },
    ).toList();

    return BoardState(columns: columns);
  }
}

class QuizBoardCategorySeed {
  const QuizBoardCategorySeed({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}