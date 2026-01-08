import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PaymentProvider with ChangeNotifier {
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = false;
  Map<String, dynamic> _currentOrder = {};

  List<Map<String, dynamic>> get plans => _plans;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get currentOrder => _currentOrder;

  Future<void> fetchPlans() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await ApiService.getSubscriptionPlans();
      _plans = List<Map<String, dynamic>>.from(response.data['plans']);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      rethrow;
    }
  }

  Future<void> createOrder(String planId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await ApiService.createOrder(planId);
      _currentOrder = response.data['order'];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      rethrow;
    }
  }

  Future<void> processPayment(Map<String, dynamic> paymentIntentData) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 确认支付
      await ApiService.confirmPayment(
        _currentOrder['id'],
        paymentIntentData,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      rethrow;
    }
  }
}
