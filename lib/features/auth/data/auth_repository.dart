import '../../../core/network/api_client.dart';

class AuthRepository {
  final ApiClient api;
  AuthRepository(this.api);

  Future<Map<String,dynamic>> register(String username,String email,String password) =>
      api.post('/auth/register',{'username':username,'email':email,'password':password});

  Future<Map<String,dynamic>> login(String login,String password) =>
      api.post('/auth/login',{'login':login,'password':password});
}
