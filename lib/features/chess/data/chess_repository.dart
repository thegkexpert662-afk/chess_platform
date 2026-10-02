import '../../../core/network/api_client.dart';

class ChessRepository {
  final ApiClient api;
  ChessRepository(this.api);

  Future<Map<String,dynamic>> joinQueue({String timeControl='600+0'}) =>
      api.post('/matchmaking/join',{'timeControl':timeControl});

  Future<Map<String,dynamic>> game(String id) => api.get('/games/'+id);

  Future<Map<String,dynamic>> move(String id,String from,String to,{String? promotion}) =>
      api.post('/games/'+id+'/moves',{'from':from,'to':to,if(promotion!=null)'promotion':promotion});

  Future<Map<String,dynamic>> resign(String id) => api.post('/matchmaking/'+id+'/resign',{});
}
