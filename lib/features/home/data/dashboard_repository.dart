import 'package:chess_platform/core/network/app_services.dart';

class DashboardRepository {
  Future<Map<String,dynamic>> dashboard() => apiClient.get('/dashboard');
  Future<Map<String,dynamic>> coins() => apiClient.get('/dashboard/coins');
  Future<Map<String,dynamic>> notifications() => apiClient.get('/dashboard/notifications');
  Future<Map<String,dynamic>> tournaments() => apiClient.get('/dashboard/tournaments');
  Future<Map<String,dynamic>> settings() => apiClient.get('/dashboard/settings');
  Future<Map<String,dynamic>> computer() => apiClient.get('/dashboard/computer');
}
