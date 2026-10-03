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

    String? promotion;
    final selectedPiece = pieceAt(fen, int.parse(selected!.substring(1)) == 8 ? 0 : 8 - int.parse(selected!.substring(1)), selected!.codeUnitAt(0) - 97);
    final destinationRank = int.parse(s.substring(1));
    if (selectedPiece?.toLowerCase() == 'p' && (destinationRank == 1 || destinationRank == 8)) {
      promotion = await _choosePromotion();
      if (promotion == null) {
        if (mounted) setState(() => selected = null);
        return;
      }
    }

    setState(() => busy = true);
    try {
      final data = await repo.move(widget.gameId, selected!, s, promotion: promotion);
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

  Future<String?> _choosePromotion() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _panel,
        title: const Text(
          'Choose promotion',
          style: TextStyle(color: _cream, fontWeight: FontWeight.w800),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _promotionButton('q', '♛', 'Queen'),
            _promotionButton('r', '♜', 'Rook'),
            _promotionButton('b', '♝', 'Bishop'),
            _promotionButton('n', '♞', 'Knight'),
          ],
        ),
      ),
    );
  }

  Widget _promotionButton(String value, String icon, String label) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 62,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: _panel2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _gold.withValues(alpha: .7)),
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(
                fontSize: 34,
                color: _cream,
                shadows: [
                  Shadow(color: Colors.black87, blurRadius: 3, offset: Offset(2, 2)),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _cream, fontSize: 9, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    refreshGame();
    if (apiClient.token != null) {
      realtime.connect(
        token: apiClient.token!,
        gameId: widget.gameId,
        onMessage: (message) {
          if ((message['type'] == 'game_update' || message['type'] == 'game_finished') && mounted) {
            refreshGame();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    realtime.dispose();
    super.dispose();
  }

  String _formatLastMove() {
    final move = game?['lastMove'] as Map?;
    if (move == null) return 'No moves yet';
    final uci = (move['move_uci'] ?? '').toString();
    if (uci.length < 4) return uci;
    final from = uci.substring(0, 2);
    final to = uci.substring(2, 4);
    final promotion = uci.length > 4 ? '=' + uci.substring(4).toUpperCase() : '';
    final playerId = move['player_id']?.toString();
    final label = playerId != null && playerId == currentUserId() ? 'You' : 'Opponent';
    return '$label: $from-$to$promotion';
  }

  Future<bool> _exitGame() async {
    final status = (game?['game']?['status'] ?? 'active').toString();
    if (status == 'active') {
      try {
        await repo.resign(widget.gameId);
      } catch (_) {
        // The WebSocket disconnect handler also forfeits an active game.
      }
    }
    return true;
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
    final status = (position['status'] ?? 'active').toString();
    final kingSquare = position['kingSquare']?.toString();
    final checkingSquares = ((position['checkingSquares'] as List?) ?? const [])
        .map((e) => e.toString())
        .toSet();

    return WillPopScope(
      onWillPop: _exitGame,
      child: Scaffold(
        backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: _panel, foregroundColor: _cream, elevation: 0, titleSpacing: 8,
        leading: IconButton(
          tooltip: 'Exit game',
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final leave = await _exitGame();
            if (leave && mounted) Navigator.of(context).pop();
          },
        ),
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
              child: _board(fen, compact, status, kingSquare, checkingSquares),
            ))),
            _playerBar(myColor, false, _clockText(myColor.toLowerCase()), myColor.toLowerCase() == (isWhiteTurn ? 'white' : 'black')),
            SizedBox(
              height: 42,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _formatLastMove(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _cream, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (status == 'check' || status == 'checkmate') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'checkmate' ? const Color(0xFF6E1515) : const Color(0xFF8B1E1E),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.redAccent.withValues(alpha: .75)),
                        ),
                        child: Text(
                          status == 'checkmate'
                              ? 'CHECKMATE • From ' + checkingSquares.join(', ')
                              : 'CHECK • King ' + (kingSquare ?? '-') + ' • From ' + checkingSquares.join(', '),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    Icon(busy ? Icons.sync : Icons.circle, size: 9, color: _gold),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: refreshGame,
                      style: TextButton.styleFrom(foregroundColor: _gold, padding: EdgeInsets.zero, minimumSize: Size.zero),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            ),
          ].join('
')

        }),
        ),
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

  Widget _board(String fen, bool compact, String status, String? kingSquare, Set<String> checkingSquares) {
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
              final isCheckKing = status == 'check' && kingSquare == squareName;
              final isCheckingPiece = checkingSquares.contains(squareName);
              return InkWell(
                onTap: busy ? null : () => tapSquare(displayRow, displayCol),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  color: isCheckKing
                      ? Colors.red.withValues(alpha: .78)
                      : isCheckingPiece
                          ? Colors.red.withValues(alpha: .38)
                          : isSelected
                              ? _gold.withValues(alpha: .72)
                              : (light ? _boardLight : _boardDark),
                  alignment: Alignment.center,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: _piece3D(
                            piece,
                            compact ? 38 : 48,
                          ),
                        ),
                      ),
                      if (displayCol == 0)
                        Positioned(
                          left: 3,
                          top: 2,
                          child: Text(
                            (isBlackPlayer ? displayRow + 1 : 8 - displayRow).toString(),
                            style: TextStyle(
                              color: light ? _boardDark : _boardLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      if (displayRow == 7)
                        Positioned(
                          right: 3,
                          bottom: 1,
                          child: Text(
                            String.fromCharCode(97 + (isBlackPlayer ? 7 - displayCol : displayCol)),
                            style: TextStyle(
                              color: light ? _boardDark : _boardLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
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

  Widget _piece3D(String? piece, double size) {
    if (piece == null) return const SizedBox.shrink();

    final isWhite = piece == piece.toUpperCase();
    final symbol = pieceToUnicode(piece);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Deep lower edge gives both sides the same dimensional chess-piece feel.
        Text(
          symbol,
          style: TextStyle(
            fontSize: size,
            color: isWhite
                ? const Color(0xFFB79A72)
                : const Color(0xFF070503),
            fontWeight: FontWeight.w900,
            shadows: const [
              Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(2.5, 3.5)),
              Shadow(color: Color(0xFF6D4A27), blurRadius: 1, offset: Offset(-1, -1)),
            ],
          ),
        ),
        Text(
          symbol,
          style: TextStyle(
            fontSize: size,
            color: isWhite
                ? const Color(0xFFFFF8E8)
                : const Color(0xFF17120D),
            fontWeight: FontWeight.w900,
            shadows: isWhite
                ? const [
                    Shadow(color: Color(0xFF6B5035), blurRadius: 2, offset: Offset(1.5, 2)),
                    Shadow(color: Colors.white70, blurRadius: 1, offset: Offset(-1, -1)),
                  ]
                : const [
                    Shadow(color: Color(0xFFE2C48B), blurRadius: 1, offset: Offset(-1, -1)),
                    Shadow(color: Colors.black87, blurRadius: 3, offset: Offset(2, 2)),
                  ],
          ),
        ),
      ],
    );
  }

  String pieceToUnicode(String? p) {
    const m = {'K':'♔','Q':'♕','R':'♖','B':'♗','N':'♘','P':'♙','k':'♚','q':'♛','r':'♜','b':'♝','n':'♞','p':'♟'};
    return m[p] ?? '';
  }
}
