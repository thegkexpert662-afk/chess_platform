enum ChessColor { white, black }

enum ChessPieceType {
  king,
  queen,
  rook,
  bishop,
  knight,
  pawn,
}

class ChessPiece {
  const ChessPiece({
    required this.type,
    required this.color,
  });

  final ChessPieceType type;
  final ChessColor color;
}

class ChessGame {
  const ChessGame();

  // Server-authoritative game state will be added here.
}
