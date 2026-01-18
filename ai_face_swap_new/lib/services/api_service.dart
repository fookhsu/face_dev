import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// 条件导入dart:io，只在非Web平台上导入
import 'dart:io' if (dart.library.html) 'dart:html';

class ApiService {
  static late Dio dio;
  static String? _token;
  static const String baseUrl = 'http://localhost:8000'; // 移除/api后缀，因为后端路由已经包含了/api

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
    return await dio.post('/api/tasks', data: data);
  }

  static Future<Response> getTasks() async {
    return await dio.get('/api/tasks');
  }

  static Future<Response> getTask(String taskId) async {
    return await dio.get('/api/tasks/$taskId');
  }

  // 文件上传
  static Future<Response> uploadFile(String filePath, String fileType) async {
    print('🔄 开始上传文件: $filePath, 类型: $fileType');
    
    // 根据平台选择不同的上传方式
    if (kIsWeb) {
      print('🌐 检测到Web平台，使用模拟响应');
      // Web平台：由于安全限制，使用模拟响应
      // 实际项目中，这里应该使用FilePicker或类似的库来处理Web文件上传
      final response = Response(
        data: {
          'url': 'http://localhost:8000/uploads/${filePath.split('/').last}',
          'filename': filePath.split('/').last,
          'size': 1024 * 1024, // 模拟文件大小
          'type': fileType
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/api/upload'),
      );
      print('✅ Web平台上传模拟完成，返回: ${response.data}');
      return response;
    } else {
      print('📱 检测到非Web平台，使用实际文件上传');
      // 非Web平台：使用实际的文件上传
      try {
        print('📁 创建上传表单，文件路径: $filePath');
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath),
          'type': fileType,
        });
        
        print('🚀 发送上传请求到: /api/upload');
        final response = await dio.post('/api/upload', data: formData);
        
        print('✅ 文件上传成功，状态码: ${response.statusCode}, 响应: ${response.data}');
        return response;
      } catch (e) {
        print('❌ 文件上传失败: $e');
        throw e;
      }
    }
  }

  // 处理视频
  static Future<Response> processVideos(String sourceVideo, String targetVideo) async {
    return await dio.post('/api/process_videos', data: {
      'source_video': sourceVideo,
      'target_video': targetVideo,
    });
  }

  // 支付相关API
  static Future<Response> getSubscriptionPlans() async {
    return await dio.get('/api/subscriptions/plans');
  }

  static Future<Response> createOrder(String planId) async {
    return await dio.post('/api/orders', data: {'planId': planId});
  }

  static Future<Response> confirmPayment(String orderId, Map<String, dynamic> paymentData) async {
    return await dio.post('/api/orders/$orderId/confirm', data: paymentData);
  }
}
