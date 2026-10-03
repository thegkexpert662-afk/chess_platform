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
  Future<void> tapSquare(int row, int col) async {
    final s = square(row, col);
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
              final row = index ~/ 8, col = index % 8;
              final piece = pieceAt(fen, row, col);
              final light = (row + col).isEven;
              return InkWell(onTap: busy ? null : () => tapSquare(row, col), child: Container(
                color: light ? const Color(0xFFF0D9B5) : const Color(0xFFB58863),
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