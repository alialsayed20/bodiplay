import 'package:flutter/material.dart';

import '../../../board/application/factories/quiz_board_initial_state_factory.dart';
import '../../../board/domain/models/board_state.dart';
import '../../../session/domain/models/game_session.dart';
import '../../presentation/widgets/quiz_battle_entry_scope.dart';

class QuizBattleMatchLauncher {
  const QuizBattleMatchLauncher({
    required QuizBoardInitialStateFactory boardFactory,
  }) : _boardFactory = boardFactory;

  final QuizBoardInitialStateFactory _boardFactory;

  Future<void> launch({
    required BuildContext context,
    required GameSession session,
  }) async {
    final BoardState board = _buildBoard();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizBattleEntryScope(
          session: session,
          board: board,
        ),
      ),
    );
  }

  BoardState _buildBoard() {
    return _boardFactory.create(
      categories: const <QuizBoardCategorySeed>[
        QuizBoardCategorySeed(
          id: 'geography',
          title: 'Geography',
        ),
        QuizBoardCategorySeed(
          id: 'science',
          title: 'Science',
        ),
        QuizBoardCategorySeed(
          id: 'history',
          title: 'History',
        ),
      ],
    );
  }
}