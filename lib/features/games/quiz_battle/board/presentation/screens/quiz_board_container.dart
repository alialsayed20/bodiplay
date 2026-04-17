import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../l10n/app_localizations.dart';
import '../../../helpers/domain/enums/helper_scope.dart';
import '../../../helpers/domain/models/helper_usage.dart';
import '../../../question/application/providers/selected_question_notifier.dart';
import '../../../question/application/state/selected_question_state.dart';
import '../../../question/presentation/screens/quiz_question_screen.dart';
import '../../../question/presentation/widgets/steal_team_selector_sheet.dart';
import '../../../question/presentation/widgets/stop_team_selector_sheet.dart';
import '../../../results/application/state/game_result_state.dart';
import '../../../results/domain/services/game_result_service.dart';
import '../../../results/presentation/screens/quiz_result_screen.dart';
import '../../../shared/application/models/quiz_match_bootstrap_data.dart';
import '../../../shared/application/providers/quiz_match_flow_providers.dart';
import '../../../shared/application/state/quiz_match_flow_state.dart';
import '../../domain/models/board_cell.dart';
import 'quiz_board_screen.dart';

class QuizBoardContainer extends ConsumerStatefulWidget {
  const QuizBoardContainer({
    super.key,
    required this.bootstrap,
  });

  final QuizMatchBootstrapData bootstrap;

  @override
  ConsumerState<QuizBoardContainer> createState() =>
      _QuizBoardContainerState();
}

class _QuizBoardContainerState extends ConsumerState<QuizBoardContainer> {
  String? _selectedBoardHelperId;
  final GameResultService _resultService = const GameResultService();

  GameResultState? _resultState;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    /// 🔥 NEW: family provider
    final QuizMatchFlowState matchState =
        ref.watch(quizMatchFlowNotifierProvider(widget.bootstrap));

    final quizNotifier =
        ref.read(quizMatchFlowNotifierProvider(widget.bootstrap).notifier);

    final SelectedQuestionState selectedQuestionState =
        ref.watch(selectedQuestionNotifierProvider);

    final questionNotifier =
        ref.read(selectedQuestionNotifierProvider.notifier);

    /// 🔥 نهاية المباراة
    if (_resultState != null && _resultState!.isFinished) {
      return QuizResultScreen(
        resultState: _resultState!,
        onClosePressed: () {
          Navigator.of(context).pop();
        },
      );
    }

    final activeRound = matchState.activeRound;

    _checkMatchEnd(matchState);

    /// ===============================
    /// شاشة السؤال
    /// ===============================
    if (activeRound != null) {
      final String winnerTeamId =
          activeRound.currentAnsweringTeamId ??
              matchState.session.currentTeamId ??
              '';

      final String questionText = _resolveQuestionText(
        l10n: l10n,
        selectedQuestionState: selectedQuestionState,
      );

      return QuizQuestionScreen(
        session: matchState.session,
        round: activeRound,
        questionText: questionText,
        onCorrectPressed: () {
          if (winnerTeamId.isEmpty) return;

          quizNotifier.resolveRound(
            winnerTeamId: winnerTeamId,
            cellId: activeRound.questionId,
          );

          questionNotifier.clear();
          _resetHelperSelection();
        },
        onWrongPressed: () {
          quizNotifier.markCurrentTeamWrong();
        },
        onClosePressed: () {
          quizNotifier.closeRoundWithoutWinner(
            cellId: activeRound.questionId,
          );

          questionNotifier.clear();
          _resetHelperSelection();
        },
        onStealPressed: () async {
          final String? firstTeamId =
              activeRound.answerOrder.isNotEmpty
                  ? activeRound.answerOrder.first.teamId
                  : null;

          if (firstTeamId == null) return;

          await showModalBottomSheet<void>(
            context: context,
            builder: (_) {
              return StealTeamSelectorSheet(
                teams: matchState.session.teams,
                excludedTeamId: firstTeamId,
                onTeamSelected: (teamId) {
                  quizNotifier.applyStealQuestion(
                    stealingTeamId: teamId,
                  );
                },
              );
            },
          );
        },
        onStopPressed: () async {
          await showModalBottomSheet<void>(
            context: context,
            builder: (_) {
              return StopTeamSelectorSheet(
                teams: matchState.session.teams,
                currentTeamId: activeRound.currentAnsweringTeamId,
                onTeamSelected: (teamId) {
                  quizNotifier.applyStopPlayer(
                    teamId: teamId,
                  );
                },
              );
            },
          );
        },
      );
    }

    /// ===============================
    /// شاشة البورد
    /// ===============================
    final List<HelperUsage> boardHelpers =
        _buildBoardHelpers(matchState.helperUsages);

    return QuizBoardScreen(
      session: matchState.session,
      board: matchState.board,
      helperUsages: boardHelpers,
      selectedHelperId: _selectedBoardHelperId,
      onBoardHelperPressed: (helperUsage) {
        setState(() {
          _selectedBoardHelperId =
              _selectedBoardHelperId == helperUsage.id
                  ? null
                  : helperUsage.id;
        });

        quizNotifier.activateBoardHelper(
          helperId: helperUsage.id,
          relatedQuestionId: helperUsage.id,
        );
      },
      onCellTap: (BoardCell cell) async {
        quizNotifier.startRound(
          cellId: cell.id,
          questionId: cell.id,
        );

        await questionNotifier.loadQuestion(
          categoryId: cell.categoryId,
          pointValue: cell.pointValue,
          languageCode:
              Localizations.localeOf(context).languageCode,
        );
      },
      onMorePressed: () {},
    );
  }

  void _checkMatchEnd(QuizMatchFlowState state) {
    if (_resultState != null) return;

    final bool shouldFinish = _resultService.shouldFinishMatch(
      session: state.session,
      board: state.board,
    );

    if (!shouldFinish) return;

    final winner = _resultService.resolveWinner(state.session);
    final leaderboard =
        _resultService.buildLeaderboard(state.session);

    setState(() {
      _resultState = GameResultState(
        isFinished: true,
        winner: winner,
        leaderboard: leaderboard,
      );
    });
  }

  void _resetHelperSelection() {
    if (!mounted) return;

    setState(() {
      _selectedBoardHelperId = null;
    });
  }

  List<HelperUsage> _buildBoardHelpers(
    List<HelperUsage> allHelpers,
  ) {
    return allHelpers
        .where((h) => h.scope == HelperScope.board)
        .toList();
  }

  String _resolveQuestionText({
    required AppLocalizations l10n,
    required SelectedQuestionState selectedQuestionState,
  }) {
    if (selectedQuestionState.isLoading) {
      return l10n.quizQuestionLoading;
    }

    if (selectedQuestionState.hasQuestion) {
      return selectedQuestionState.question!.text;
    }

    if (selectedQuestionState.hasError) {
      return selectedQuestionState.errorMessage ==
              'Failed to load question'
          ? l10n.quizQuestionLoadFailed
          : l10n.quizQuestionUnavailable;
    }

    return l10n.quizQuestionUnavailable;
  }
}