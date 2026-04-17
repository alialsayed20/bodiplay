import '../../domain/models/player.dart';
import '../../domain/models/setup_state.dart';
import '../../domain/models/team.dart';
import '../../../board/domain/enums/board_cell_status.dart';
import '../../../board/domain/models/board_category_column.dart';
import '../../../board/domain/models/board_cell.dart';
import '../../../board/domain/models/board_state.dart';
import '../../../session/domain/enums/game_session_status.dart';
import '../../../session/domain/models/game_session.dart';
import '../../../session/domain/models/session_player_snapshot.dart';
import '../../../session/domain/models/session_team_snapshot.dart';
import '../../../session/domain/models/turn_order.dart';
import '../models/start_match_result.dart';

class StartMatchService {
  const StartMatchService();

  StartMatchResult start(SetupState setup) {
    final List<Team> validTeams = setup.teams
        .where((Team team) => team.name.trim().isNotEmpty)
        .toList();

    final List<Player> validPlayers = setup.players
        .where((Player player) =>
            player.name.trim().isNotEmpty && player.teamId != null)
        .toList();

    if (validTeams.length < 2) {
      return StartMatchResult.failure(
        'At least 2 valid teams are required.',
      );
    }

    if (validPlayers.length < 2) {
      return StartMatchResult.failure(
        'At least 2 valid players are required.',
      );
    }

    final Set<String> validTeamIds =
        validTeams.map((Team team) => team.id).toSet();

    final List<SessionTeamSnapshot> sessionTeams = validTeams
        .map(
          (Team team) => SessionTeamSnapshot(
            id: team.id,
            name: team.name,
            colorValue: team.colorValue,
            playerIds: team.playerIds
                .where((String playerId) {
                  return validPlayers.any(
                    (Player player) =>
                        player.id == playerId && player.teamId == team.id,
                  );
                })
                .toList(),
            score: 0,
            isEliminated: false,
          ),
        )
        .toList();

    final List<SessionPlayerSnapshot> sessionPlayers = validPlayers
        .where((Player player) => validTeamIds.contains(player.teamId))
        .map(
          (Player player) => SessionPlayerSnapshot(
            id: player.id,
            name: player.name,
            teamId: player.teamId!,
          ),
        )
        .toList();

    if (sessionPlayers.length < 2) {
      return StartMatchResult.failure(
        'No valid assigned players were found.',
      );
    }

    final List<String> orderedTeamIds = sessionTeams
        .where((SessionTeamSnapshot team) => team.playerIds.isNotEmpty)
        .map((SessionTeamSnapshot team) => team.id)
        .toList();

    if (orderedTeamIds.length < 2) {
      return StartMatchResult.failure(
        'At least 2 teams with assigned players are required.',
      );
    }

    final int startingIndex = setup.startingTeamId == null
        ? 0
        : orderedTeamIds.indexOf(setup.startingTeamId!);

    final int resolvedStartingIndex =
        startingIndex == -1 ? 0 : startingIndex;

    final TurnOrder turnOrder = TurnOrder(
      teamIds: orderedTeamIds,
      currentIndex: resolvedStartingIndex,
    );

    final GameSession session = GameSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      status: GameSessionStatus.active,
      teams: sessionTeams,
      players: sessionPlayers,
      turnOrder: turnOrder,
      createdAt: DateTime.now(),
    );

    final BoardState board = _buildInitialBoard();

    return StartMatchResult.success(
      session: session,
      board: board,
    );
  }

  BoardState _buildInitialBoard() {
    const List<_CategorySeed> categories = <_CategorySeed>[
      _CategorySeed(id: 'geography', title: 'Geography'),
      _CategorySeed(id: 'science', title: 'Science'),
      _CategorySeed(id: 'history', title: 'History'),
      _CategorySeed(id: 'sports', title: 'Sports'),
      _CategorySeed(id: 'general', title: 'General'),
    ];

    const List<int> pointValues = <int>[10, 25, 50, 100];

    return BoardState(
      columns: categories.map((category) {
        return BoardCategoryColumn(
          categoryId: category.id,
          title: category.title,
          cells: pointValues.map((int pointValue) {
            return BoardCell(
              id: '${category.id}_$pointValue',
              categoryId: category.id,
              pointValue: pointValue,
              status: BoardCellStatus.available,
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _CategorySeed {
  const _CategorySeed({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}