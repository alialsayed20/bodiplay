import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/models/start_match_result.dart';
import '../../application/providers/setup_providers.dart';
import '../../application/providers/start_match_providers.dart';
import '../../domain/models/player.dart';
import '../../domain/models/setup_state.dart';
import '../../domain/models/team.dart';
import '../widgets/setup_category_picking_section.dart';
import '../widgets/setup_lottery_section.dart';
import '../../../shared/presentation/widgets/quiz_battle_entry_scope.dart';

class SetupSandboxScreen extends ConsumerWidget {
  const SetupSandboxScreen({super.key});

  static const List<SetupCategoryOption> _availableCategories =
      <SetupCategoryOption>[
    SetupCategoryOption(id: 'geography', title: 'Geography'),
    SetupCategoryOption(id: 'science', title: 'Science'),
    SetupCategoryOption(id: 'history', title: 'History'),
    SetupCategoryOption(id: 'sports', title: 'Sports'),
    SetupCategoryOption(id: 'general', title: 'General'),
    SetupCategoryOption(id: 'movies', title: 'Movies'),
    SetupCategoryOption(id: 'music', title: 'Music'),
    SetupCategoryOption(id: 'technology', title: 'Technology'),
    SetupCategoryOption(id: 'animals', title: 'Animals'),
    SetupCategoryOption(id: 'food', title: 'Food'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(setupControllerProvider);
    final controller = ref.read(setupControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Sandbox'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                _PlayersSection(
                  players: state.setup.players,
                  onAddPlayer: controller.addPlayer,
                  onNameChanged: ({
                    required String playerId,
                    required String name,
                  }) {
                    controller.updatePlayerName(
                      playerId: playerId,
                      name: name,
                    );
                  },
                ),
                const SizedBox(height: 20),
                _TeamsSection(
                  teams: state.setup.teams,
                  players: state.setup.players,
                  onAddTeam: controller.addTeam,
                  onNameChanged: ({
                    required String teamId,
                    required String name,
                  }) {
                    controller.updateTeamName(
                      teamId: teamId,
                      name: name,
                    );
                  },
                  onColorChanged: ({
                    required String teamId,
                    required int colorValue,
                  }) {
                    controller.updateTeamColor(
                      teamId: teamId,
                      colorValue: colorValue,
                    );
                  },
                  onAssignPlayer: ({
                    required String playerId,
                    required String teamId,
                  }) {
                    controller.assignPlayerToTeam(
                      playerId: playerId,
                      teamId: teamId,
                    );
                  },
                ),
                const SizedBox(height: 20),
                SetupLotterySection(
                  setup: state.setup,
                  onRunLottery: controller.runLottery,
                  onResetLottery: controller.resetLottery,
                ),
                const SizedBox(height: 20),
                SetupCategoryPickingSection(
                  setup: state.setup,
                  availableCategories: _availableCategories,
                  onPickCategory: ({
                    required String teamId,
                    required String categoryId,
                  }) {
                    controller.pickCategory(
                      teamId: teamId,
                      categoryId: categoryId,
                    );
                  },
                  onResetPicking: controller.resetCategoryPicking,
                ),
                const SizedBox(height: 20),
                _StatusSection(
                  setup: state.setup,
                  canStartMatch:
                      state.canStartMatch && state.setup.isReady,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: state.canStartMatch && state.setup.isReady
                      ? () {
                          _startMatch(
                            context: context,
                            ref: ref,
                            setup: state.setup,
                          );
                        }
                      : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Start Match'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startMatch({
    required BuildContext context,
    required WidgetRef ref,
    required SetupState setup,
  }) {
    final StartMatchResult result =
        ref.read(startMatchServiceProvider).start(setup);

    if (result.isFailure || result.session == null || result.board == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage ?? 'Failed to start match.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizBattleEntryScope(
          session: result.session!,
          board: result.board!,
        ),
      ),
    );
  }
}

class _PlayersSection extends StatelessWidget {
  const _PlayersSection({
    required this.players,
    required this.onAddPlayer,
    required this.onNameChanged,
  });

  final List<Player> players;
  final VoidCallback onAddPlayer;
  final void Function({
    required String playerId,
    required String name,
  }) onNameChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Players',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...players.map(
              (Player player) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Player name',
                    labelText: player.id,
                  ),
                  onChanged: (String value) {
                    onNameChanged(
                      playerId: player.id,
                      name: value,
                    );
                  },
                ),
              ),
            ),
            OutlinedButton(
              onPressed: onAddPlayer,
              child: const Text('Add Player'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamsSection extends StatelessWidget {
  const _TeamsSection({
    required this.teams,
    required this.players,
    required this.onAddTeam,
    required this.onNameChanged,
    required this.onColorChanged,
    required this.onAssignPlayer,
  });

  final List<Team> teams;
  final List<Player> players;
  final VoidCallback onAddTeam;
  final void Function({
    required String teamId,
    required String name,
  }) onNameChanged;
  final void Function({
    required String teamId,
    required int colorValue,
  }) onColorChanged;
  final void Function({
    required String playerId,
    required String teamId,
  }) onAssignPlayer;

  static const List<int> _presetColors = <int>[
    0xFFF44336,
    0xFF2196F3,
    0xFF4CAF50,
    0xFFFF9800,
    0xFF9C27B0,
    0xFF009688,
    0xFFFFC107,
    0xFF795548,
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Teams',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...teams.map(
              (Team team) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Team name',
                        labelText: team.id,
                      ),
                      onChanged: (String value) {
                        onNameChanged(
                          teamId: team.id,
                          name: value,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Team Color',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presetColors.map((int colorValue) {
                        final bool isSelected =
                            team.colorValue == colorValue;

                        return GestureDetector(
                          onTap: () {
                            onColorChanged(
                              teamId: team.id,
                              colorValue: colorValue,
                            );
                          },
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Color(colorValue),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Assign Players',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      children: players.map((Player player) {
                        final bool isAssigned =
                            team.playerIds.contains(player.id);

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Checkbox(
                              value: isAssigned,
                              onChanged: (_) {
                                onAssignPlayer(
                                  playerId: player.id,
                                  teamId: team.id,
                                );
                              },
                            ),
                            Text(
                              player.name.isEmpty ? player.id : player.name,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            OutlinedButton(
              onPressed: onAddTeam,
              child: const Text('Add Team'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({
    required this.setup,
    required this.canStartMatch,
  });

  final SetupState setup;
  final bool canStartMatch;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Current Step: ${setup.step.name}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Starting Team: ${setup.startingTeamId ?? "Not decided"}',
            ),
            const SizedBox(height: 8),
            Text(
              'Current Picking Team: ${setup.currentPickingTeamId ?? "None"}',
            ),
            const SizedBox(height: 8),
            Text(
              'Selected Categories: ${setup.selectedCategoryIds.length}',
            ),
            const SizedBox(height: 8),
            Text(
              'Can Start Match: $canStartMatch',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}