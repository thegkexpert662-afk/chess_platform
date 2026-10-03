import 'dart:async';
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
  Timer? _clockTimer;
  int _whiteMs = 0, _blackMs = 0;
  String _clockTurn = 'white';
  DateTime? _clockStartedAt;

  static const _page = Color(0xFF17110B);
  static const _panel = Color(0xFF24180D);
  static const _panel2 = Color(0xFF302014);
  static const _gold = Color(0xFFD6A84F);
  static const _cream = Color(0xFFF4E6C8);
  static const _boardLight = Color(0xFFF0D8AE);
  static const _boardDark = Color(0xFF8A5D36);
  static const _ink = Color(0xFF2B1B10);

  Future<void> refreshGame() async {
    try {
      final data = await repo.game(widget.gameId);
      if (!mounted) return;
      setState(() { game = data; _syncClock(data); });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _syncClock(Map<String, dynamic> data) {
    final g = data['game'] as Map;
    _whiteMs = (g['white_time_ms'] as num?)?.toInt() ?? 0;
    _blackMs = (g['black_time_ms'] as num?)?.toInt() ?? 0;
    _clockTurn = (g['next_turn'] ?? data['position']['turn'] ?? 'white').toString();
    final raw = g['turn_started_at'];
    _clockStartedAt = raw == null ? DateTime.now() : DateTime.tryParse(raw.toString());
    _clockTimer ??= Timer.periodic(const Duration(milliseconds: 250), (_) { if (mounted) setState(() {}); });
  }

  int _displayMs(String side) {
    var value = side == 'white' ? _whiteMs : _blackMs;
    if (_clockStartedAt != null && _clockTurn == side && game?['game']?['status'] == 'active') {
      value -= DateTime.now().difference(_clockStartedAt!).inMilliseconds;
    }
    return value.clamp(0, 24 * 60 * 60 * 1000);
  }

  String _clockText(String side) {
    final totalSeconds = (_displayMs(side) / 1000).ceil();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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
      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      return payload['sub']?.toString();
    } catch (_) { return null; }
  }

  bool get isBlackPlayer {
    final userId = currentUserId();
    final g = game;
    if (g == null || userId == null) return false;
    return (g['game'] as Map)['black_player_id']?.toString() == userId;
  }

  Future<void> tapSquare(int row, int col) async {
    final actualRow = isBlackPlayer ? 7 - row : row;
    final actualCol = isBlackPlayer ? 7 - col : col;
    final s = square(actualRow, actualCol);
    final fen = game!['position']['fen'] as String;

    final piece = pieceAt(fen, actualRow, actualCol);
    final turn = (game!['position']['turn'] ?? 'white').toString();
    final myColor = isBlackPlayer ? 'black' : 'white';
    final isMyTurn = turn == myColor;

    if (selected == null) {
      if (!isMyTurn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('It is not your turn.')),
        );
        return;
      }
      if (piece == null) return;

      final isWhitePiece = piece == piece.toUpperCase();
      final pieceColor = isWhitePiece ? 'white' : 'black';
      if (pieceColor != myColor) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can move only your own pieces.')),
        );
        return;
      }

      setState(() => selected = s);
      return;
    }

    // If the second tap is another one of your pieces, select that piece instead.
    if (piece != null) {
      final isWhitePiece = piece == piece.toUpperCase();
      final pieceColor = isWhitePiece ? 'white' : 'black';
      if (pieceColor == myColor) {
        setState(() => selected = s);
        return;
      }
    }

    if (!isMyTurn) {
      setState(() => selected = null);
      return;
    }

    setState(() => busy = true);
    try {
      final data = await repo.move(widget.gameId, selected!, s);
      if (mounted) setState(() { game = data; selected = null; _syncClock(data); });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => selected = null);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    refreshGame();
    if (apiClient.token != null) {
      realtime.connect(
        token: apiClient.token!,
        gameId: widget.gameId,
        onMessage: (message) { if (message['type'] == 'game_update' && mounted) refreshGame(); },
      );
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    realtime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = game;
    if (g == null) return const Scaffold(backgroundColor: _page, body: Center(child: CircularProgressIndicator()));

    final position = g['position'] as Map;
    final fen = position['fen'] as String;
    final isWhiteTurn = position['turn'] == 'white';
    final myColor = isBlackPlayer ? 'Black' : 'White';
    final opponentColor = isBlackPlayer ? 'White' : 'Black';

    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: _panel, foregroundColor: _cream, elevation: 0, titleSpacing: 18,
        title: Row(children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.emoji_events, color: _ink, size: 22)),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CHESS PLATFORM', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1.2)),
            Text('KOPERSAY TECHNOLOGY', style: TextStyle(fontSize: 9, letterSpacing: 2.0, color: _gold)),
          ]),
        ]),
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxHeight < 720;
          return Column(children: [
            _playerBar(opponentColor, true, _clockText(opponentColor.toLowerCase()), opponentColor.toLowerCase() == (isWhiteTurn ? 'white' : 'black')),
            Expanded(child: Center(child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 14, vertical: compact ? 4 : 8),
              child: _board(fen, compact),
            ))),
            _playerBar(myColor, false, _clockText(myColor.toLowerCase()), myColor.toLowerCase() == (isWhiteTurn ? 'white' : 'black')),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.circle, size: 9, color: _gold),
                const SizedBox(width: 6),
                Text(busy ? 'Submitting move…' : 'Server turn: ${position['turn']}',
                  style: const TextStyle(color: _cream, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                TextButton(onPressed: refreshGame,
                  style: TextButton.styleFrom(foregroundColor: _gold, padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: Size.zero),
                  child: const Text('Refresh')),
              ]),
            ),
          ]);
        }),
      ),
    );
  }

  Widget _playerBar(String colorName, bool isTop, String clock, bool active) {
    final isWhite = colorName.toLowerCase() == 'white';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Container(
        height: 54,
        decoration: BoxDecoration(color: _panel2, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? _gold : const Color(0xFF59432B), width: active ? 1.5 : 1)),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(children: [
          CircleAvatar(radius: 18, backgroundColor: isWhite ? _cream : const Color(0xFF171717),
            child: Icon(Icons.person, size: 22, color: isWhite ? _ink : Colors.white70)),
          const SizedBox(width: 9),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isTop ? 'Opponent ($colorName)' : 'You ($colorName)',
              style: const TextStyle(color: _cream, fontSize: 14, fontWeight: FontWeight.w700)),
            Row(children: [
              Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF28C76F), shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(active ? (isTop ? 'Opponent turn' : 'Your turn') : 'Online', style: TextStyle(color: active ? _gold : Colors.white60, fontSize: 10)),
            ]),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(color: _page, borderRadius: BorderRadius.circular(9), border: Border.all(color: _gold.withValues(alpha: .65))),
            child: Row(children: [
              const Icon(Icons.access_time, color: _gold, size: 18),
              const SizedBox(width: 6),
              Text(clock, style: const TextStyle(color: _cream, fontSize: 18, fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()])),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _board(String fen, bool compact) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: _gold, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 5))]),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(), padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), itemCount: 64,
            itemBuilder: (context, index) {
              final displayRow = index ~/ 8;
              final displayCol = index % 8;
              final boardRow = isBlackPlayer ? 7 - displayRow : displayRow;
              final boardCol = isBlackPlayer ? 7 - displayCol : displayCol;
              final piece = pieceAt(fen, boardRow, boardCol);
              final squareName = square(boardRow, boardCol);
              final light = (displayRow + displayCol).isEven;
              final isSelected = selected == squareName;
              return InkWell(
                onTap: busy ? null : () => tapSquare(displayRow, displayCol),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  color: isSelected ? _gold.withValues(alpha: .72) : (light ? _boardLight : _boardDark),
                  alignment: Alignment.center,
                  child: FittedBox(fit: BoxFit.contain, child: Text(pieceToUnicode(piece),
                    style: TextStyle(fontSize: compact ? 27 : 34,
                      color: piece != null && piece == piece.toUpperCase() ? const Color(0xFFFFF8E8) : const Color(0xFF18110C),
                      shadows: const [Shadow(color: Colors.black38, blurRadius: 2, offset: Offset(1, 1))]))),
                ),
              );
            },
          ),
          IgnorePointer(child: Center(child: Opacity(opacity: .18, child: Column(mainAxisSize: MainAxisSize.min, children: const [
            Icon(Icons.emoji_events, color: _ink, size: 46),
            SizedBox(height: 2),
            Text('KOPERSAY', style: TextStyle(color: _ink, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 3)),
            Text('TECHNOLOGY', style: TextStyle(color: _ink, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 4)),
          ])))),
        ]),
      ),
    );
  }

  String pieceToUnicode(String? p) {
    const m = {'K':'♔','Q':'♕','R':'♖','B':'♗','N':'♘','P':'♙','k':'♚','q':'♛','r':'♜','b':'♝','n':'♞','p':'♟'};
    return m[p] ?? '';
  }
}
