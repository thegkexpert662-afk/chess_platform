import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiClient {
  String? token;

  Map<String,String> get _headers => {
    'Content-Type':'application/json',
    if(token != null) 'Authorization':'Bearer ' + token!,
  };

  Future<Map<String,dynamic>> post(String path, Map<String,dynamic> body) async {
    final response=await http.post(Uri.parse(ApiConfig.baseUrl+path),headers:_headers,body:jsonEncode(body));
    return _decode(response);
  }

  Future<Map<String,dynamic>> get(String path) async {
    final response=await http.get(Uri.parse(ApiConfig.baseUrl+path),headers:_headers);
    return _decode(response);
  }

  Map<String,dynamic> _decode(http.Response response) {
    final data=jsonDecode(response.body.isEmpty?'{}':response.body);
    if(response.statusCode<200 || response.statusCode>=300) {
      final error=data is Map ? data['error'] : null;
      final message=error is Map ? error['message'] : null;
      throw Exception(message ?? 'Request failed (' + response.statusCode.toString() + ')');
    }
    return Map<String,dynamic>.from(data as Map);
  }
}
