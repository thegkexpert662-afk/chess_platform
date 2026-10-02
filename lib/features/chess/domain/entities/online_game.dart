class OnlineGame {
  final String id;
  final String status;
  final String turn;
  final String fen;
  final String? result;
  final int whiteTimeMs;
  final int blackTimeMs;

  const OnlineGame({
    required this.id, required this.status, required this.turn, required this.fen,
    required this.result, required this.whiteTimeMs, required this.blackTimeMs,
  });

  factory OnlineGame.fromJson(Map<String,dynamic> json) {
    final game=Map<String,dynamic>.from(json['game'] as Map);
    final position=Map<String,dynamic>.from(json['position'] as Map);
    return OnlineGame(
      id:game['id'] as String,
      status:game['status'] as String,
      turn:position['turn'] as String,
      fen:position['fen'] as String,
      result:game['result'] as String?,
      whiteTimeMs:int.tryParse(game['white_time_ms'].toString()) ?? 0,
      blackTimeMs:int.tryParse(game['black_time_ms'].toString()) ?? 0,
    );
  }
}
