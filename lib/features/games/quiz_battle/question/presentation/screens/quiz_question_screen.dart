import 'package:flutter/material.dart';

import '../../../../../../l10n/app_localizations.dart';
import '../../domain/models/answer_order_entry.dart';
import '../../domain/models/question_round.dart';
import '../../../session/domain/models/game_session.dart';
import '../../../session/domain/models/session_team_snapshot.dart';
import '../widgets/quiz_question_actions_bar.dart';
import '../widgets/quiz_question_card.dart';
import '../widgets/quiz_question_shell.dart';
import '../widgets/quiz_question_turn_strip.dart';

class QuizQuestionScreen extends StatelessWidget {
  const QuizQuestionScreen({
    super.key,
    required this.session,
    required this.round,
    required this.questionText,
    required this.onCorrectPressed,
    required this.onWrongPressed,
    required this.onClosePressed,
    this.onStealPressed,
    this.onStopPressed,
  });

  final GameSession session;
  final QuestionRound round;
  final String questionText;
  final VoidCallback onCorrectPressed;
  final VoidCallback onWrongPressed;
  final VoidCallback onClosePressed;
  final VoidCallback? onStealPressed;
  final VoidCallback? onStopPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final Map<String, String> teamNamesById = <String, String>{
      for (final SessionTeamSnapshot team in session.teams) team.id: team.name,
    };

    final Map<String, Color> teamColorsById = <String, Color>{
      for (final SessionTeamSnapshot team in session.teams)
        team.id: Color(team.colorValue),
    };

    return QuizQuestionShell(
      title: l10n.quizQuestionRoundTitle,
      subtitle: _buildSubtitle(l10n, teamNamesById),
      topBar: QuizQuestionTurnStrip(
        answerOrder: round.answerOrder,
        currentTeamId: round.currentAnsweringTeamId,
        teamNamesById: teamNamesById,
        teamColorsById: teamColorsById,
      ),
      body: QuizQuestionCard(
        questionText: questionText,
        pointValue: round.pointValue,
      ),
      bottomBar: QuizQuestionActionsBar(
        onCorrectPressed: onCorrectPressed,
        onWrongPressed: onWrongPressed,
        onClosePressed: onClosePressed,
        onStealPressed: _canSteal() ? onStealPressed : null,
        onStopPressed: _canStop() ? onStopPressed : null,
        canSteal: _canSteal(),
        canStop: _canStop(),
        canMarkCorrect:
            round.currentAnsweringTeamId != null && !round.isClosed,
        canMarkWrong:
            round.currentAnsweringTeamId != null && !round.isClosed,
        canClose: !round.isClosed,
      ),
    );
  }

  String _buildSubtitle(
    AppLocalizations l10n,
    Map<String, String> teamNamesById,
  ) {
    if (round.isClosed) {
      return l10n.quizQuestionClosed;
    }

    final String? currentTeamId = round.currentAnsweringTeamId;
    if (currentTeamId == null) {
      return l10n.quizQuestionWaitingResolution;
    }

    return l10n.quizQuestionNowAnswering(
      teamNamesById[currentTeamId] ?? currentTeamId,
    );
  }

  bool _canSteal() {
    if (round.isClosed) {
      return false;
    }

    if (round.isStealBlocked) {
      return false;
    }

    if (!round.isStealAvailable) {
      return false;
    }

    if (round.answerOrder.isEmpty) {
      return false;
    }

    final String firstTeamId = round.answerOrder.first.teamId;
    final String? currentTeamId = round.currentAnsweringTeamId;

    if (currentTeamId == null || currentTeamId.trim().isEmpty) {
      return false;
    }

    if (currentTeamId == firstTeamId) {
      return false;
    }

    final AnswerOrderEntry? currentEntry = _findEntryByTeamId(currentTeamId);
    if (currentEntry == null || !currentEntry.canAnswer) {
      return false;
    }

    return true;
  }

  bool _canStop() {
    if (round.isClosed) {
      return false;
    }

    if (round.status.name != 'answering') {
      return false;
    }

    final List<AnswerOrderEntry> eligibleTargets = round.answerOrder
        .where((AnswerOrderEntry entry) {
      if (!entry.canAnswer) {
        return false;
      }

      if (entry.teamId == round.currentAnsweringTeamId) {
        return false;
      }

      return true;
    }).toList();

    return eligibleTargets.isNotEmpty;
  }

  AnswerOrderEntry? _findEntryByTeamId(String teamId) {
    for (final AnswerOrderEntry entry in round.answerOrder) {
      if (entry.teamId == teamId) {
        return entry;
      }
    }
    return null;
  }
}