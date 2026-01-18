#!/usr/bin/env python3
"""
测试上传功能
"""

import grpc
import os
import sys
import time
from concurrent import futures

# 添加当前目录到路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import video_service_pb2
import video_service_pb2_grpc


def test_upload():
    """测试上传功能"""
    print("开始测试上传功能...")
    
    # 创建 gRPC 通道
    channel = grpc.insecure_channel('localhost:50051')
    
    # 创建客户端
    stub = video_service_pb2_grpc.VideoServiceStub(channel)
    
    try:
        # 模拟上传文件
        file_path = "test_file.txt"
        
        # 创建测试文件
        with open(file_path, "w") as f:
            f.write("This is a test file for uploading.")
        
        # 读取文件内容
        with open(file_path, "rb") as f:
            file_content = f.read()
        
        # 设置分片大小
        chunk_size = 1024
        total_chunks = (len(file_content) + chunk_size - 1) // chunk_size
        
        # 创建上传请求流
        def request_generator():
            for i in range(total_chunks):
                start = i * chunk_size
                end = (i + 1) * chunk_size
                chunk_data = file_content[start:end]
                
                yield video_service_pb2.UploadRequest(
                    user_id="test_user",
                    file_name="test_file.txt",
                    chunk=chunk_data,
                    chunk_index=i,
                    total_chunks=total_chunks,
                    file_type="file"
                )
        
        # 调用上传方法
        responses = stub.UploadVideo(request_generator())
        
        # 处理响应
        for response in responses:
            print(f"上传状态: {response.status}")
            print(f"消息: {response.message}")
            print(f"进度: {response.progress:.2f}%")
            print(f"已上传分片: {response.uploaded_chunks}/{response.total_chunks}")
            print()
        
        print("上传测试成功!")
        
    except Exception as e:
        print(f"测试失败: {str(e)}")
    finally:
        # 清理测试文件
        if os.path.exists(file_path):
            os.remove(file_path)
        
        # 关闭通道
        channel.close()


if __name__ == "__main__":
    test_upload()
