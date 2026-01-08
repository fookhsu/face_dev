import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  // 使用内存存储替代Hive
  Map<String, dynamic> _user = {};
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic> get user => _user;

  Future<void> login(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);
      final token = response.data['token'];
      final user = response.data['user'];
      
      // 存储到内存
      _user = user;
      _isAuthenticated = true;
      
      // 设置API服务的token
      ApiService.setToken(token);
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String email, String password, String username) async {
    try {
      final response = await ApiService.register(email, password, username);
      final token = response.data['token'];
      final user = response.data['user'];
      
      // 存储到内存
      _user = user;
      _isAuthenticated = true;
      
      // 设置API服务的token
      ApiService.setToken(token);
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    // 清除内存存储
    _user = {};
    _isAuthenticated = false;
    
    // 清除API服务的token
    ApiService.clearToken();
    
    notifyListeners();
  }
}
