# AI视频换脸应用 - 完整技术方案

## 1. 整体架构设计

### 1.1 系统架构
- **前端**：Flutter跨平台应用（支持iOS、Android、macOS、Web）
- **后端**：Python + FastAPI + gRPC
- **AI服务**：独立的AI换脸模型服务（基于DeepFaceLab或类似框架）
- **存储**：对象存储（如AWS S3、阿里云OSS）
- **数据库**：MongoDB（用户数据、任务记录）
- **消息推送**：Firebase Cloud Messaging (FCM)
- **支付系统**：集成第三方支付（如Stripe、微信支付、支付宝）

### 1.2 核心功能模块

#### 用户模块
- 用户注册/登录（手机号验证码、第三方登录）
- 用户信息管理
- 会员等级与权益管理

#### 支付模块
- 会员套餐展示
- 支付流程集成
- 订单管理
- 会员状态同步

#### 视频处理模块
- 图片/视频上传功能
- 任务提交与队列管理
- 视频生成状态查询
- 消息推送通知
- 生成视频下载

#### AI换脸模块
- 人脸检测与对齐
- 面部特征提取
- 视频帧处理
- 视频合成与渲染

## 2. 技术栈选择

### 2.1 前端技术栈
- **框架**：Flutter 3.x
- **状态管理**：Provider或Riverpod
- **网络请求**：Dio + gRPC
- **本地存储**：Hive
- **图片/视频处理**：image_picker、video_player
- **推送服务**：firebase_messaging
- **支付集成**：flutter_stripe、flutter_alipay等

### 2.2 后端技术栈
- **框架**：Python + FastAPI + gRPC
- **数据库**：MongoDB
- **ORM**：Pymongo
- **认证**：JWT
- **文件存储**：AWS S3 SDK
- **消息队列**：Redis + Bull（任务队列）
- **推送服务**：firebase-admin
- **gRPC库**：grpcio, grpcio-tools
- **Protocol Buffers**：protobuf
- **文件处理**：Pillow, FFmpeg-python

### 2.3 AI服务技术栈
- **深度学习框架**：PyTorch或TensorFlow
- **人脸处理库**：OpenCV、dlib
- **换脸模型**：基于DeepFaceLab或自定义训练模型
- **容器化**：Docker

## 3. 数据库设计

### 3.1 用户表（users）
- `_id`：用户ID
- `phone`：手机号
- `email`：邮箱
- `password`：加密密码
- `nickname`：昵称
- `avatar`：头像URL
- `member_level`：会员等级
- `member_expire_at`：会员到期时间
- `created_at`：创建时间
- `updated_at`：更新时间

### 3.2 任务表（tasks）
- `_id`：任务ID
- `user_id`：用户ID
- `image_url`：上传图片URL
- `video_url`：上传视频URL
- `result_url`：生成结果URL
- `status`：任务状态（pending, processing, completed, failed）
- `progress`：处理进度（0-100）
- `created_at`：创建时间
- `updated_at`：更新时间

### 3.3 订单表（orders）
- `_id`：订单ID
- `user_id`：用户ID
- `amount`：金额
- `currency`：货币类型
- `status`：订单状态（pending, paid, failed, refunded）
- `product_id`：产品ID
- `transaction_id`：支付交易ID
- `created_at`：创建时间
- `updated_at`：更新时间

### 3.4 产品表（products）
- `_id`：产品ID
- `name`：产品名称
- `description`：产品描述
- `price`：价格
- `duration`：有效期（天）
- `features`：权益列表
- `created_at`：创建时间

## 4. 前后端交互方案

### 4.1 交互协议

#### RESTful API（推荐）
- **现状**：项目中已使用Dio实现RESTful API请求
- **优势**：简单易用，广泛支持，适合异步任务
- **实现**：
  - 使用HTTP/HTTPS协议
  - 基于JSON格式传输数据
  - 使用标准的HTTP方法（GET, POST, PUT, DELETE）
  - 实现RESTful API端点

#### gRPC（可选）
- **优势**：高性能，适合大量数据传输
- **适用场景**：
  - 传输大型视频文件
  - 高性能要求的场景
- **实现**：
  - 定义Protobuf消息格式
  - 生成前后端代码
  - 实现gRPC服务

#### WebSocket（可选）
- **优势**：实时通信，适合任务进度更新
- **适用场景**：
  - 实时显示任务进度
  - 实时通知任务完成
- **实现**：
  - 在前端使用WebSocket客户端
  - 后端使用WebSocket服务器
  - 建立持久连接，推送任务状态更新

### 4.2 数据传输内容

#### 用户认证数据
- **传输时机**：所有需要认证的请求
- **传输方式**：HTTP头部的Authorization字段（Bearer Token）
- **数据内容**：JWT Token

#### 图片/视频上传
- **传输时机**：用户创建换脸任务时
- **传输方式**：
  - FormData（推荐）：使用multipart/form-data格式
  - Base64编码：适合小图片
  - gRPC流式上传：适合大视频文件
- **数据内容**：
  - 目标图片文件
  - 视频文件
  - 用户ID
  - 任务配置参数

#### 任务状态数据
- **传输时机**：
  - 前端定期轮询
  - 后端主动推送
- **数据内容**：
  - 任务ID
  - 任务状态（pending, processing, completed, failed）
  - 任务进度（0-100%）
  - 预计完成时间

#### 生成结果数据
- **传输时机**：任务完成时
- **数据内容**：
  - 任务ID
  - 生成的视频URL
  - 生成的视频缩略图
  - 任务耗时
  - 消耗的资源（Energy/Magic）

### 4.3 后台任务通知机制

#### Firebase Cloud Messaging（FCM）推送通知
- **优势**：跨平台支持，实时通知
- **实现步骤**：
  - 在Firebase控制台配置项目
  - 在前端集成FCM SDK
  - 后端在任务完成时发送推送通知
  - 前端处理通知，显示任务完成消息

#### 轮询机制
- **优势**：实现简单，无需额外服务
- **实现步骤**：
  - 前端定期发送GET请求查询任务状态
  - 后端返回最新的任务状态
  - 前端根据状态更新UI

#### 组合方案
- **推荐**：结合FCM推送和轮询机制
  - 轮询：定期检查任务状态，更新进度
  - FCM推送：任务完成时立即通知用户

### 4.4 前后端交互流程

#### 用户认证流程
1. 用户登录/注册
2. 后端生成JWT Token
3. 前端存储Token
4. 所有请求携带Token
5. 后端验证Token

#### 任务创建流程
1. 用户选择图片和视频
2. 前端调用API上传文件
3. 后端接收文件并存储
4. 后端创建任务，返回任务ID
5. 前端显示任务ID和初始状态

#### 任务处理流程
1. 后端将任务加入队列
2. 模型服务处理任务
3. 后端更新任务状态和进度
4. 前端定期轮询获取进度
5. 任务完成后，后端发送FCM通知

#### 结果获取流程
1. 用户点击通知或查看任务列表
2. 前端调用API获取结果
3. 后端返回生成的视频URL
4. 用户点击下载按钮下载视频

## 5. 模型部署方案

### 5.1 云服务器部署
- **方案**：将AI模型部署在云服务器上，如AWS EC2、GCP Compute Engine或Azure VM
- **优势**：完全控制服务器环境，适合大型模型和高并发场景
- **实现步骤**：
  - 选择合适的云服务器实例（推荐GPU实例）
  - 安装CUDA、cuDNN等深度学习依赖
  - 部署模型服务（如TensorFlow Serving、TorchServe或FastAPI + Uvicorn）
  - 配置负载均衡和自动缩放

### 5.2 容器化部署
- **方案**：使用Docker容器化模型服务，配合Kubernetes进行管理
- **优势**：环境隔离、易于部署和扩展
- **实现步骤**：
  - 编写Dockerfile，包含模型和依赖
  - 构建Docker镜像并推送到镜像仓库
  - 使用Kubernetes部署服务
  - 配置Ingress和Service

### 5.3 Serverless部署
- **方案**：使用无服务器架构，如AWS Lambda、Google Cloud Functions或Azure Functions
- **优势**：按需付费，无需管理服务器
- **实现步骤**：
  - 将模型转换为适合Serverless的轻量版本
  - 编写函数代码，处理请求和返回结果
  - 部署函数并配置API Gateway

## 6. gRPC服务实现

### 6.1 服务和消息定义

创建`proto/video_service.proto`文件：

```protobuf
syntax = "proto3";

package video;

// 视频上传请求消息
message UploadRequest {
  string user_id = 1;
  string file_name = 2;
  bytes chunk = 3;
  int32 chunk_index = 4;
  int32 total_chunks = 5;
  string file_type = 6; // image/video
}

// 视频上传响应消息
message UploadResponse {
  string status = 1;
  string message = 2;
  string file_url = 3;
  int32 uploaded_chunks = 4;
  int32 total_chunks = 5;
}

// 任务创建请求消息
message CreateTaskRequest {
  string user_id = 1;
  string image_url = 2;
  string video_url = 3;
}

// 任务响应消息
message TaskResponse {
  string task_id = 1;
  string status = 2; // pending, processing, completed, failed
  int32 progress = 3;
  string result_url = 4;
  string error_message = 5;
}

// 任务状态查询请求
message TaskStatusRequest {
  string task_id = 1;
}

// 视频服务定义
service VideoService {
  // 流式上传视频
  rpc UploadVideo(stream UploadRequest) returns (UploadResponse);
  
  // 创建换脸任务
  rpc CreateTask(CreateTaskRequest) returns (TaskResponse);
  
  // 获取任务状态
  rpc GetTaskStatus(TaskStatusRequest) returns (TaskResponse);
}
```

### 6.2 后端实现

#### 核心服务逻辑
```python
# video_service.py
import grpc
from concurrent import futures
from proto import video_service_pb2, video_service_pb2_grpc

class VideoService(video_service_pb2_grpc.VideoServiceServicer):
    def UploadVideo(self, request_iterator, context):
        # 处理流式上传
        file_path = ""
        uploaded_chunks = 0
        total_chunks = 0
        
        for request in request_iterator:
            # 初始化文件路径和总块数
            if not file_path:
                total_chunks = request.total_chunks
                file_path = self._get_file_path(request.file_name)
                
            # 写入分片
            self._write_chunk(file_path, request.chunk, request.chunk_index)
            uploaded_chunks += 1
            
            # 返回上传进度
            yield video_service_pb2.UploadResponse(
                status="uploading",
                uploaded_chunks=uploaded_chunks,
                total_chunks=total_chunks
            )
        
        # 上传完成，返回结果
        file_url = f"/uploads/{request.file_name}"
        return video_service_pb2.UploadResponse(
            status="completed",
            message="Upload successful",
            file_url=file_url,
            uploaded_chunks=uploaded_chunks,
            total_chunks=total_chunks
        )
    
    def CreateTask(self, request, context):
        # 创建换脸任务
        task_id = self._generate_task_id()
        # 存储任务到数据库
        # 启动异步处理
        return video_service_pb2.TaskResponse(
            task_id=task_id,
            status="pending",
            progress=0
        )
    
    def GetTaskStatus(self, request, context):
        # 获取任务状态
        task = self._get_task(request.task_id)
        return video_service_pb2.TaskResponse(
            task_id=task.id,
            status=task.status,
            progress=task.progress,
            result_url=task.result_url,
            error_message=task.error_message
        )
    
    # 辅助方法
    def _get_file_path(self, filename):
        # 生成文件存储路径
        pass
    
    def _write_chunk(self, file_path, chunk, chunk_index):
        # 写入分片到文件
        pass
    
    def _generate_task_id(self):
        # 生成唯一任务ID
        pass
    
    def _get_task(self, task_id):
        # 从数据库获取任务
        pass
```

### 6.3 前端实现

#### gRPC客户端实现
```dart
import 'package:grpc/grpc.dart';
import 'lib/grpc/video_service.pbgrpc.dart';

class VideoClient {
  late VideoServiceClient _client;
  
  VideoClient() {
    final channel = ClientChannel(
      'localhost',
      port: 50051,
      options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    _client = VideoServiceClient(channel);
  }
  
  // 上传视频方法
  Stream<UploadResponse> uploadVideo(
    String userId,
    String fileName,
    List<int> fileBytes,
    String fileType,
  ) async* {
    // 分片大小：10MB
    const int chunkSize = 10 * 1024 * 1024;
    final int totalChunks = (fileBytes.length / chunkSize).ceil();
    
    // 创建请求流
    final requestStream = Stream<UploadRequest>.fromIterable(
      [
        for (int i = 0; i < totalChunks; i++)
          UploadRequest()
            ..userId = userId
            ..fileName = fileName
            ..chunk = fileBytes.sublist(
              i * chunkSize,
              (i + 1) * chunkSize > fileBytes.length
                  ? fileBytes.length
                  : (i + 1) * chunkSize,
            )
            ..chunkIndex = i
            ..totalChunks = totalChunks
            ..fileType = fileType,
      ],
    );
    
    // 调用gRPC服务
    final response = await _client.uploadVideo(requestStream);
    yield response;
  }
  
  // 创建任务方法
  Future<TaskResponse> createTask(
    String userId,
    String imageUrl,
    String videoUrl,
  ) async {
    final request = CreateTaskRequest()
      ..userId = userId
      ..imageUrl = imageUrl
      ..videoUrl = videoUrl;
    
    return await _client.createTask(request);
  }
  
  // 获取任务状态
  Future<TaskResponse> getTaskStatus(String taskId) async {
    final request = GetTaskStatusRequest()..taskId = taskId;
    return await _client.getTaskStatus(request);
  }
}
```

## 7. 实现步骤

### 7.1 项目初始化
- 创建Flutter项目
- 配置项目依赖
- 设置Git版本控制

### 7.2 前端基础架构搭建
- 搭建Flutter项目结构
- 配置状态管理
- 实现网络请求封装
- 配置本地存储
- 集成推送服务

### 7.3 后端服务搭建
- 初始化后端项目
- 配置数据库连接
- 实现用户认证系统
- 搭建API框架
- 实现gRPC服务

### 7.4 用户模块实现
- 前端：注册/登录页面
- 前端：用户信息页面
- 后端：用户相关API实现
- 数据库：用户表设计与实现

### 7.5 支付模块实现
- 前端：会员套餐展示页面
- 前端：支付流程实现
- 后端：订单管理API
- 集成第三方支付SDK

### 7.6 视频处理模块实现
- 前端：图片/视频上传功能
- 前端：任务列表与详情页面
- 后端：任务管理API
- 实现消息推送通知
- 集成gRPC文件上传

### 7.7 AI换脸服务实现
- 搭建AI服务环境
- 实现人脸检测与处理
- 实现视频帧处理与合成
- 集成到后端任务队列

### 7.8 测试与优化
- 单元测试与集成测试
- 性能优化
- 用户体验优化
- 安全性测试

### 7.9 部署上线
- 前端应用打包发布
- 后端服务部署（云服务器或容器平台）
- AI服务部署与 scaling
- 配置域名与SSL
- 监控系统搭建

## 8. 数据安全考虑

### 8.1 数据加密
- **传输加密**：使用HTTPS协议
- **存储加密**：对敏感用户数据和生成的视频进行加密存储

### 8.2 身份验证和授权
- **JWT Token**：用于用户认证
- **权限控制**：基于角色的访问控制
- **API限流**：防止滥用

### 8.3 数据隐私
- **用户数据保护**：遵守GDPR、CCPA等隐私法规
- **数据删除机制**：允许用户删除自己的数据
- **匿名处理**：对敏感数据进行匿名化处理

## 9. 部署架构示意图

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Flutter App   │────▶│  API Gateway    │────▶│  Backend Server │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                        │
                                                        ▼
                                          ┌─────────────────┐
                                          │  Task Queue     │
                                          └────────┬────────┘
                                                   │
          ┌─────────────────┐     ┌────────┴────────┐
          │  FCM Server      │◀────┤  Model Service  │
          └────────┬────────┘     └─────────────────┘
                   │
                   ▼
          ┌─────────────────┐
          │   Flutter App   │
          └─────────────────┘
```

## 10. 技术优势与注意事项

### 10.1 技术优势
- **跨平台**：Flutter实现一次开发，多平台运行
- **高性能**：gRPC提供高效的视频传输
- **可扩展**：模块化设计，易于功能扩展
- **实时通知**：FCM提供及时的任务完成通知
- **安全可靠**：完善的身份验证和数据加密

### 10.2 注意事项
- **性能优化**：图片/视频上传前进行压缩，AI服务采用GPU加速
- **安全性**：用户数据加密存储，API接口认证与授权
- **用户体验**：清晰的任务进度展示，及时的消息通知
- **扩展性**：模块化设计，便于功能扩展
- **资源管理**：合理设置服务器资源，避免过载

## 11. 后续优化方向

1. **添加认证**：使用gRPC拦截器实现认证
2. **加密传输**：使用TLS加密gRPC连接
3. **断点续传**：实现分片状态记录和恢复
4. **负载均衡**：添加gRPC负载均衡支持
5. **监控告警**：添加监控和告警机制
6. **AI模型优化**：使用轻量级模型，提高处理速度
7. **边缘计算**：考虑在边缘节点部署模型，减少延迟
8. **多语言支持**：添加国际化支持
