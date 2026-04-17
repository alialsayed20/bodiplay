import '../enums/board_cell_status.dart';

class BoardCell {
  const BoardCell({
    required this.id,
    required this.categoryId,
    required this.pointValue,
    required this.status,
    this.ownerTeamId,
  });

  final String id;
  final String categoryId;
  final int pointValue;
  final BoardCellStatus status;
  final String? ownerTeamId;

  bool get isAvailable => status == BoardCellStatus.available;
  bool get isUsed => status == BoardCellStatus.used;

  BoardCell copyWith({
    String? id,
    String? categoryId,
    int? pointValue,
    BoardCellStatus? status,
    String? ownerTeamId,
    bool clearOwner = false,
  }) {
    return BoardCell(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      pointValue: pointValue ?? this.pointValue,
      status: status ?? this.status,
      ownerTeamId:
          clearOwner ? null : (ownerTeamId ?? this.ownerTeamId),
    );
  }
}