import 'dart:async';
import 'dart:io';
import 'package:grpc/grpc.dart';
import '../src/generated/video_service.pbgrpc.dart';

class GrpcService {
  static final GrpcService _instance = GrpcService._internal();
  factory GrpcService() => _instance;

  late VideoServiceClient _client;
  late ClientChannel _channel;

  GrpcService._internal() {
    // 创建gRPC通道
    _channel = ClientChannel(
      'localhost',
      port: 50051,
      options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        idleTimeout: Duration(minutes: 1),
      ),
    );

    // 创建gRPC客户端
    _client = VideoServiceClient(_channel);
  }

  /// 上传文件到服务器
  Future<String?> uploadFile({
    required File file,
    required String userId,
    required String fileType, // image/video
    Function(double progress)? onProgress,
  }) async {
    try {
      // 设置分片大小
      const int chunkSize = 1024 * 1024; // 1MB
      final int fileSize = await file.length();
      final int totalChunks = (fileSize + chunkSize - 1) ~/ chunkSize;
      String? finalFileUrl;

      // 创建上传请求流
      Stream<UploadRequest> requestStream() async* {
        for (int i = 0; i < totalChunks; i++) {
          final int start = i * chunkSize;
          final int end = (i + 1) * chunkSize > fileSize ? fileSize : (i + 1) * chunkSize;
          final List<int> chunkData = await file.readAsBytes().then((bytes) => bytes.sublist(start, end));

          yield UploadRequest()
            ..userId = userId
            ..fileName = file.path.split('/').last
            ..chunk = chunkData
            ..chunkIndex = i
            ..totalChunks = totalChunks
            ..fileType = fileType;
        }
      }

      // 调用gRPC上传方法
      final responses = _client.uploadVideo(requestStream());

      // 处理上传响应
      await for (final response in responses) {
        if (onProgress != null) {
          onProgress(response.progress);
        }

        if (response.status == 'completed') {
          finalFileUrl = response.fileUrl;
          break;
        } else if (response.status == 'failed') {
          throw Exception('Upload failed: ${response.message}');
        }
      }

      return finalFileUrl;
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  /// 创建换脸任务
  Future<TaskResponse> createTask({
    required String userId,
    required String imageUrl,
    required String videoUrl,
  }) async {
    try {
      final request = CreateTaskRequest()
        ..userId = userId
        ..imageUrl = imageUrl
        ..videoUrl = videoUrl;

      final response = await _client.createTask(request);
      return response;
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  /// 获取任务状态
  Future<TaskResponse> getTaskStatus({required String taskId}) async {
    try {
      final request = TaskStatusRequest()..taskId = taskId;
      final response = await _client.getTaskStatus(request);
      return response;
    } catch (e) {
      print('Error getting task status: $e');
      rethrow;
    }
  }

  /// 获取用户任务列表
  Future<UserTasksResponse> getUserTasks({required String userId}) async {
    try {
      final request = UserTasksRequest()..userId = userId;
      final response = await _client.getUserTasks(request);
      return response;
    } catch (e) {
      print('Error getting user tasks: $e');
      rethrow;
    }
  }

  /// 关闭gRPC通道
  void dispose() {
    _channel.shutdown();
  }
}