import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/network/api_config.dart';

class GameRealtimeService {
  WebSocketChannel? _channel;

  void connect({
    required String token,
    required String gameId,
    required void Function(Map<String,dynamic>) onMessage,
  }) {
    final base=ApiConfig.baseUrl.replaceFirst('/api','/ws');
    final uri=Uri.parse(base.replaceFirst('https://','wss://').replaceFirst('http://','ws://'));
    _channel=WebSocketChannel.connect(uri);
    _channel!.stream.listen((raw){
      try {
        final data=jsonDecode(raw.toString());
        if(data is Map) onMessage(Map<String,dynamic>.from(data));
      } catch (_) {}
    },onDone:()=>_channel=null,onError:(_)=>_channel=null);
    _channel!.sink.add(jsonEncode({'type':'auth','token':token,'gameId':gameId}));
  }

  void dispose(){
    _channel?.sink.close();
    _channel=null;
  }
}
