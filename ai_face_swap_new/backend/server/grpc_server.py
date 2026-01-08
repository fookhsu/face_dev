#!/usr/bin/env python3
"""
AI视频换脸应用 - gRPC服务端启动脚本
"""

import os
import logging
import grpc
from concurrent import futures
import video_service_pb2_grpc
from video_service import VideoService

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('grpc_server.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# gRPC服务器配置
GRPC_PORT = 50051
MAX_WORKERS = 10

def serve():
    """启动gRPC服务器"""
    logger.info(f'启动gRPC服务器，监听端口: {GRPC_PORT}')
    
    # 创建gRPC服务器
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=MAX_WORKERS))
    
    # 注册服务
    video_service_pb2_grpc.add_VideoServiceServicer_to_server(VideoService(), server)
    
    # 添加安全认证（可选）
    # 这里使用简单的不安全连接，生产环境应该使用TLS
    server.add_insecure_port(f'[::]:{GRPC_PORT}')
    
    # 启动服务器
    server.start()
    logger.info(f'gRPC服务器启动成功，监听端口: {GRPC_PORT}')
    
    # 保持服务器运行
    try:
        server.wait_for_termination()
    except KeyboardInterrupt:
        logger.info('gRPC服务器正在关闭...')
        server.stop(0)
        logger.info('gRPC服务器已关闭')

if __name__ == '__main__':
    serve()
