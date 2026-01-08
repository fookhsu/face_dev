#!/usr/bin/env python3
"""
任务模型定义
"""

from datetime import datetime

class Task:
    """换脸任务模型"""
    
    def __init__(self, task_id, user_id, image_url, video_url):
        """初始化任务"""
        self.task_id = task_id
        self.user_id = user_id
        self.image_url = image_url
        self.video_url = video_url
        self.status = 'pending'  # pending, processing, completed, failed
        self.progress = 0
        self.result_url = ''
        self.error_message = ''
        self.created_at = datetime.now()
        self.updated_at = datetime.now()
    
    def to_dict(self):
        """转换为字典格式"""
        return {
            'task_id': self.task_id,
            'user_id': self.user_id,
            'image_url': self.image_url,
            'video_url': self.video_url,
            'status': self.status,
            'progress': self.progress,
            'result_url': self.result_url,
            'error_message': self.error_message,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
    
    def __str__(self):
        """字符串表示"""
        return f"Task({self.task_id}, {self.status}, {self.progress}%)"
