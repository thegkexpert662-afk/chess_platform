import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:chess_platform/core/network/app_services.dart';
import '../../data/chess_repository.dart';
import '../../data/game_realtime_service.dart';

class OnlineGameScreen extends StatefulWidget {
  final String gameId;
  const OnlineGameScreen({super.key, required this.gameId});
  @override State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}
class _OnlineGameScreenState extends State<OnlineGameScreen> {
  final repo = ChessRepository(apiClient);
  final realtime = GameRealtimeService();
  Map<String, dynamic>? game;
  String? selected;
  bool busy = false;
  Future<void> refreshGame() async {
    try {
      final data = await repo.game(widget.gameId);
      if (mounted) setState(() => game = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
  String? pieceAt(String fen, int row, int col) {
    final board = fen.split(' ')[0].split('/');
    var file = 0;
    for (final ch in board[row].split('')) {
      if (RegExp(r'[1-8]').hasMatch(ch)) file += int.parse(ch);
      else { if (file == col) return ch; file++; }
    }
    return null;
  }
  String square(int row, int col) => String.fromCharCode(97 + col) + (8 - row).toString();

  String? currentUserId() {
    final token = apiClient.token;
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      return payload['sub']?.toString();
    } catch (_) {
      return null;
    }
  }

  bool get isBlackPlayer {
    final g = game;
    final userId = currentUserId();
    if (g == null || userId == null) return false;
    final gameData = g['game'] as Map;
    return gameData['black_player_id']?.toString() == userId;
  }

  String displaySquare(int row, int col) {
    final actualRow = isBlackPlayer ? 7 - row : row;
    final actualCol = isBlackPlayer ? 7 - col : col;
    return square(actualRow, actualCol);
  }
  Future<void> tapSquare(int row, int col) async {
    final s = displaySquare(row, col);
    if (selected == null) {
      if (pieceAt(game!['position']['fen'] as String, row, col) != null) setState(() => selected = s);
      return;
    }
    setState(() => busy = true);
    try {
      final data = await repo.move(widget.gameId, selected!, s);
      if (mounted) setState(() => game = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => busy = false);
    }
    if (mounted) setState(() => selected = null);
  }
  @override void initState() {
    super.initState();
    refreshGame();
    if (apiClient.token != null) realtime.connect(token: apiClient.token!, gameId: widget.gameId, onMessage: (message) { if (message['type'] == 'game_update' && mounted) refreshGame(); });
  }
  @override void dispose() { realtime.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final g = game;
    if (g == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final position = g['position'] as Map;
    final fen = position['fen'] as String;
    return Scaffold(
      appBar: AppBar(title: const Text('Online Game')),
      body: SafeArea(child: Column(children: [
        const SizedBox(height: 6),
        Text('Server turn: ' + position['turn'].toString()),
        const SizedBox(height: 6),
        Expanded(child: LayoutBuilder(builder: (context, constraints) {
          final side = constraints.maxWidth < constraints.maxHeight ? constraints.maxWidth : constraints.maxHeight;
          return Center(child: SizedBox(width: side, height: side, child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
            itemCount: 64,
            itemBuilder: (context, index) {
              final displayRow = index ~/ 8;
              final displayCol = index % 8;
              final boardRow = isBlackPlayer ? 7 - displayRow : displayRow;
              final boardCol = isBlackPlayer ? 7 - displayCol : displayCol;
              final piece = pieceAt(fen, boardRow, boardCol);
              final light = (displayRow + displayCol).isEven;
              return InkWell(onTap: busy ? null : () => tapSquare(displayRow, displayCol), child: Container(
                color: light ? const Color(0xFFF3E6C8) : const Color(0xFF9A7653),
                alignment: Alignment.center,
                child: FittedBox(child: Text(pieceToUnicode(piece), style: const TextStyle(fontSize: 32))),
              ));
            },
          )));
        })),
        const SizedBox(height: 4),
        Text('Status: ' + g['game']['status'].toString()),
        if (g['game']['result'] != null) Text('Result: ' + g['game']['result'].toString()),
        const SizedBox(height: 4),
        OutlinedButton(onPressed: refreshGame, child: const Text('Refresh from server')),
        const SizedBox(height: 4),
      ])),
    );
  }
  String pieceToUnicode(String? p) {
    const m = {'K':'♔','Q':'♕','R':'♖','B':'♗','N':'♘','P':'♙','k':'♚','q':'♛','r':'♜','b':'♝','n':'♞','p':'♟'};
    return m[p] ?? '';
  }
}