#!/usr/bin/env python3
"""
AI视频换脸应用 - gRPC客户端测试脚本
"""

import os
import logging
import grpc
import video_service_pb2
import video_service_pb2_grpc
from datetime import datetime

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# gRPC服务器地址
GRPC_SERVER_ADDRESS = 'localhost:50051'

def test_upload_video():
    """测试视频上传功能"""
    logger.info("测试视频上传功能...")
    
    # 创建gRPC通道
    with grpc.insecure_channel(GRPC_SERVER_ADDRESS) as channel:
        # 创建客户端
        stub = video_service_pb2_grpc.VideoServiceStub(channel)
        
        # 准备测试文件
        test_file_path = os.path.join(os.path.dirname(__file__), "test_video.mp4")
        
        # 如果测试文件不存在，创建一个空文件
        if not os.path.exists(test_file_path):
            with open(test_file_path, "wb") as f:
                f.write(b"test video content")
            logger.info(f"创建测试文件: {test_file_path}")
        
        # 读取文件内容
        file_size = os.path.getsize(test_file_path)
        chunk_size = 1024  # 1KB分片
        total_chunks = (file_size + chunk_size - 1) // chunk_size
        
        # 生成上传请求迭代器
        def upload_request_generator():
            with open(test_file_path, "rb") as f:
                for i in range(total_chunks):
                    chunk = f.read(chunk_size)
                    yield video_service_pb2.UploadRequest(
                        user_id="test_user_123",
                        file_name="test_video.mp4",
                        chunk=chunk,
                        chunk_index=i,
                        total_chunks=total_chunks,
                        file_type="video"
                    )
        
        try:
            # 调用上传方法
            responses = stub.UploadVideo(upload_request_generator())
            
            # 处理响应
            for response in responses:
                logger.info(f"上传响应: status={response.status}, progress={response.progress}%, message={response.message}")
                if response.status == "completed":
                    logger.info(f"上传完成，文件URL: {response.file_url}")
                    return response.file_url
            
        except grpc.RpcError as e:
            logger.error(f"上传视频失败: {e}")
    
    return None

def test_create_task():
    """测试创建换脸任务"""
    logger.info("测试创建换脸任务...")
    
    # 创建gRPC通道
    with grpc.insecure_channel(GRPC_SERVER_ADDRESS) as channel:
        # 创建客户端
        stub = video_service_pb2_grpc.VideoServiceStub(channel)
        
        try:
            # 创建任务请求
            request = video_service_pb2.CreateTaskRequest(
                user_id="test_user_123",
                image_url="/uploads/test_image.jpg",
                video_url="/uploads/test_video.mp4"
            )
            
            # 调用创建任务方法
            response = stub.CreateTask(request)
            
            logger.info(f"创建任务响应: task_id={response.task_id}, status={response.status}, progress={response.progress}")
            return response.task_id
            
        except grpc.RpcError as e:
            logger.error(f"创建任务失败: {e}")
    
    return None

def test_get_task_status(task_id):
    """测试获取任务状态"""
    logger.info(f"测试获取任务状态，任务ID: {task_id}...")
    
    # 创建gRPC通道
    with grpc.insecure_channel(GRPC_SERVER_ADDRESS) as channel:
        # 创建客户端
        stub = video_service_pb2_grpc.VideoServiceStub(channel)
        
        try:
            # 创建状态请求
            request = video_service_pb2.TaskStatusRequest(
                task_id=task_id
            )
            
            # 调用获取任务状态方法
            response = stub.GetTaskStatus(request)
            
            logger.info(f"任务状态响应: task_id={response.task_id}, status={response.status}, progress={response.progress}, result_url={response.result_url}")
            return response
            
        except grpc.RpcError as e:
            logger.error(f"获取任务状态失败: {e}")
    
    return None

def test_get_user_tasks():
    """测试获取用户任务列表"""
    logger.info("测试获取用户任务列表...")
    
    # 创建gRPC通道
    with grpc.insecure_channel(GRPC_SERVER_ADDRESS) as channel:
        # 创建客户端
        stub = video_service_pb2_grpc.VideoServiceStub(channel)
        
        try:
            # 创建用户任务请求
            request = video_service_pb2.UserTasksRequest(
                user_id="test_user_123"
            )
            
            # 调用获取用户任务列表方法
            response = stub.GetUserTasks(request)
            
            logger.info(f"用户任务列表响应: total_tasks={response.total_tasks}")
            for task in response.tasks:
                logger.info(f"  - task_id={task.task_id}, status={task.status}, progress={task.progress}")
            
            return response
            
        except grpc.RpcError as e:
            logger.error(f"获取用户任务列表失败: {e}")
    
    return None

def main():
    """主测试函数"""
    logger.info("开始gRPC客户端测试...")
    
    # 测试1: 上传视频
    # video_url = test_upload_video()
    
    # 测试2: 创建换脸任务
    task_id = test_create_task()
    
    if task_id:
        # 测试3: 获取任务状态
        test_get_task_status(task_id)
    
    # 测试4: 获取用户任务列表
    test_get_user_tasks()
    
    logger.info("gRPC客户端测试完成!")

if __name__ == '__main__':
    main()
