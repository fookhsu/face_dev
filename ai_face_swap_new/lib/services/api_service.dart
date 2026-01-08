import 'package:dio/dio.dart';

class ApiService {
  static late Dio dio;
  static String? _token;
  static const String baseUrl = 'http://localhost:8000/api';

  static Future<void> initialize() async {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // 添加拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  // 设置token
  static void setToken(String token) {
    _token = token;
  }

  // 清除token
  static void clearToken() {
    _token = null;
  }

  // 认证相关API
  static Future<Response> login(String email, String password) async {
    return await dio.post('/auth/login', data: {'email': email, 'password': password});
  }

  static Future<Response> register(String email, String password, String username) async {
    return await dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'username': username,
    });
  }

  // 任务相关API
  static Future<Response> createTask(Map<String, dynamic> data) async {
    return await dio.post('/tasks', data: data);
  }

  static Future<Response> getTasks() async {
    return await dio.get('/tasks');
  }

  static Future<Response> getTask(String taskId) async {
    return await dio.get('/tasks/$taskId');
  }

  // 文件上传
  static Future<Response> uploadFile(String filePath, String fileType) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'type': fileType,
    });
    return await dio.post('/upload', data: formData);
  }

  // 支付相关API
  static Future<Response> getSubscriptionPlans() async {
    return await dio.get('/subscriptions/plans');
  }

  static Future<Response> createOrder(String planId) async {
    return await dio.post('/orders', data: {'planId': planId});
  }

  static Future<Response> confirmPayment(String orderId, Map<String, dynamic> paymentData) async {
    return await dio.post('/orders/$orderId/confirm', data: paymentData);
  }
}
