#!/usr/bin/env python3
"""
AI视频换脸应用 - gRPC服务实现
"""

import os
import uuid
import logging
from datetime import datetime
import grpc
from concurrent import futures

import video_service_pb2, video_service_pb2_grpc
from models.task import Task
from utils.file_processor import FileProcessor
from utils.mock_ai import MockAIModel

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 目录配置
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
UPLOAD_DIR = os.path.join(BASE_DIR, 'uploads')
OUTPUT_DIR = os.path.join(BASE_DIR, 'outputs')
TEMP_DIR = os.path.join(BASE_DIR, 'temp')

# 创建必要的目录
for dir_path in [UPLOAD_DIR, OUTPUT_DIR, TEMP_DIR]:
    if not os.path.exists(dir_path):
        os.makedirs(dir_path)
        logger.info(f'创建目录: {dir_path}')

class VideoService(video_service_pb2_grpc.VideoServiceServicer):
    """视频服务实现"""
    
    def __init__(self):
        """初始化服务"""
        self.file_processor = FileProcessor()
        self.mock_ai = MockAIModel()
        self.tasks = {}
    
    def UploadVideo(self, request_iterator, context):
        """处理流式视频上传"""
        logger.info('开始处理视频上传请求')
        
        # 初始化上传状态
        current_upload = {
            'user_id': None,
            'file_name': None,
            'file_type': None,
            'total_chunks': 0,
            'uploaded_chunks': 0,
            'temp_file_path': None
        }
        
        try:
            # 处理所有上传的分片
            for request in request_iterator:
                # 初始化上传状态
                if current_upload['user_id'] is None:
                    current_upload['user_id'] = request.user_id
                    current_upload['file_name'] = request.file_name
                    current_upload['file_type'] = request.file_type
                    current_upload['total_chunks'] = request.total_chunks
                    
                    # 创建临时文件路径
                    temp_file_name = f"{request.user_id}_{uuid.uuid4()}_{request.file_name}"
                    current_upload['temp_file_path'] = os.path.join(
                        TEMP_DIR, temp_file_name
                    )
                    logger.info(f'开始接收文件: {request.file_name}, 总分片数: {request.total_chunks}')
                
                # 写入分片到文件
                self.file_processor.write_chunk(
                    current_upload['temp_file_path'],
                    request.chunk,
                    request.chunk_index
                )
                
                # 更新上传进度
                current_upload['uploaded_chunks'] += 1
                progress = (current_upload['uploaded_chunks'] / current_upload['total_chunks']) * 100
                
                # 发送上传进度响应
                yield video_service_pb2.UploadResponse(
                    status="uploading",
                    message=f"上传中...",
                    uploaded_chunks=current_upload['uploaded_chunks'],
                    total_chunks=current_upload['total_chunks'],
                    progress=progress
                )
            
            # 所有分片上传完成，合并文件
            logger.info(f'文件上传完成: {current_upload["file_name"]}')
            
            # 移动文件到上传目录
            final_file_path = os.path.join(
                UPLOAD_DIR, current_upload['file_name']
            )
            os.rename(
                current_upload['temp_file_path'],
                final_file_path
            )
            
            # 生成文件URL
            file_url = f"/uploads/{current_upload['file_name']}"
            
            # 发送上传完成响应
            yield video_service_pb2.UploadResponse(
                status="completed",
                message="上传成功",
                file_url=file_url,
                uploaded_chunks=current_upload['uploaded_chunks'],
                total_chunks=current_upload['total_chunks'],
                progress=100.0
            )
            
        except Exception as e:
            logger.error(f'文件上传失败: {str(e)}')
            yield video_service_pb2.UploadResponse(
                status="failed",
                message=f"上传失败: {str(e)}",
                uploaded_chunks=current_upload.get('uploaded_chunks', 0),
                total_chunks=current_upload.get('total_chunks', 0),
                progress=0.0
            )
    
    def CreateTask(self, request, context):
        """创建换脸任务"""
        logger.info(f'创建换脸任务，用户ID: {request.user_id}')
        
        try:
            # 生成任务ID
            task_id = str(uuid.uuid4())
            
            # 创建任务对象
            task = Task(
                task_id=task_id,
                user_id=request.user_id,
                image_url=request.image_url,
                video_url=request.video_url
            )
            
            # 存储任务
            self.tasks[task_id] = task
            
            # 异步处理任务
            futures.ThreadPoolExecutor().submit(
                self._process_task, task_id
            )
            
            logger.info(f'任务创建成功，任务ID: {task_id}')
            
            # 返回任务响应
            return video_service_pb2.TaskResponse(
                task_id=task.task_id,
                status=task.status,
                progress=task.progress,
                result_url=task.result_url,
                error_message=task.error_message,
                created_at=task.created_at.isoformat(),
                updated_at=task.updated_at.isoformat()
            )
            
        except Exception as e:
            logger.error(f'任务创建失败: {str(e)}')
            return video_service_pb2.TaskResponse(
                task_id="",
                status="failed",
                progress=0,
                result_url="",
                error_message=str(e),
                created_at=datetime.now().isoformat(),
                updated_at=datetime.now().isoformat()
            )
    
    def GetTaskStatus(self, request, context):
        """获取任务状态"""
        logger.info(f'获取任务状态，任务ID: {request.task_id}')
        
        # 检查任务是否存在
        if request.task_id not in self.tasks:
            logger.error(f'任务不存在: {request.task_id}')
            return video_service_pb2.TaskResponse(
                task_id=request.task_id,
                status="failed",
                progress=0,
                result_url="",
                error_message="任务不存在",
                created_at=datetime.now().isoformat(),
                updated_at=datetime.now().isoformat()
            )
        
        # 获取任务
        task = self.tasks[request.task_id]
        
        logger.info(f'获取任务状态成功，任务ID: {request.task_id}, 状态: {task.status}')
        
        # 返回任务状态
        return video_service_pb2.TaskResponse(
            task_id=task.task_id,
            status=task.status,
            progress=task.progress,
            result_url=task.result_url,
            error_message=task.error_message,
            created_at=task.created_at.isoformat(),
            updated_at=task.updated_at.isoformat()
        )
    
    def GetUserTasks(self, request, context):
        """获取用户任务列表"""
        logger.info(f'获取用户任务列表，用户ID: {request.user_id}')
        
        # 过滤用户的任务
        user_tasks = [
            task for task in self.tasks.values() 
            if task.user_id == request.user_id
        ]
        
        # 转换为响应格式
        task_responses = [
            video_service_pb2.TaskResponse(
                task_id=task.task_id,
                status=task.status,
                progress=task.progress,
                result_url=task.result_url,
                error_message=task.error_message,
                created_at=task.created_at.isoformat(),
                updated_at=task.updated_at.isoformat()
            ) for task in user_tasks
        ]
        
        logger.info(f'获取用户任务列表成功，用户ID: {request.user_id}, 任务数量: {len(user_tasks)}')
        
        # 返回用户任务列表
        return video_service_pb2.UserTasksResponse(
            tasks=task_responses,
            total_tasks=len(user_tasks)
        )
    
    def _process_task(self, task_id):
        """异步处理换脸任务"""
        logger.info(f'开始处理任务，任务ID: {task_id}')
        
        try:
            # 获取任务
            task = self.tasks[task_id]
            
            # 更新任务状态为processing
            task.status = 'processing'
            task.progress = 10
            task.updated_at = datetime.now()
            
            # 模拟AI处理过程
            result_url = self.mock_ai.process_face_swap(
                task.image_url,
                task.video_url
            )
            
            # 更新任务状态为completed
            task.status = 'completed'
            task.progress = 100
            task.result_url = result_url
            task.updated_at = datetime.now()
            
            logger.info(f'任务处理成功，任务ID: {task_id}')
            
        except Exception as e:
            logger.error(f'任务处理失败，任务ID: {task_id}, 错误: {str(e)}')
            
            # 更新任务状态为failed
            task = self.tasks[task_id]
            task.status = 'failed'
            task.progress = 0
            task.error_message = str(e)
            task.updated_at = datetime.now()
