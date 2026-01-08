#!/usr/bin/env python3
"""
文件处理工具类
"""

import os
import logging
import uuid
from pathlib import Path

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class FileProcessor:
    """文件处理工具类"""
    
    def write_chunk(self, file_path, chunk_data, chunk_index):
        """写入文件分片
        
        Args:
            file_path (str): 文件路径
            chunk_data (bytes): 分片数据
            chunk_index (int): 分片索引
        """
        try:
            # 创建父目录
            Path(file_path).parent.mkdir(parents=True, exist_ok=True)
            
            # 以追加模式打开文件
            with open(file_path, 'ab') as f:
                f.write(chunk_data)
            
            logger.debug(f'成功写入分片 {chunk_index} 到文件 {file_path}')
            
        except Exception as e:
            logger.error(f'写入分片失败: {str(e)}')
            raise
    
    def merge_chunks(self, temp_dir, output_file, chunk_size=10*1024*1024):
        """合并文件分片
        
        Args:
            temp_dir (str): 临时目录，包含所有分片
            output_file (str): 输出文件路径
            chunk_size (int): 分片大小，默认10MB
        """
        try:
            logger.info(f'开始合并文件，临时目录: {temp_dir}, 输出文件: {output_file}')
            
            # 获取所有分片文件，按文件名排序
            chunk_files = sorted(
                [f for f in os.listdir(temp_dir) if f.startswith('chunk_')],
                key=lambda x: int(x.split('_')[1])
            )
            
            # 创建父目录
            Path(output_file).parent.mkdir(parents=True, exist_ok=True)
            
            # 合并所有分片
            with open(output_file, 'wb') as out_f:
                for chunk_file in chunk_files:
                    chunk_path = os.path.join(temp_dir, chunk_file)
                    with open(chunk_path, 'rb') as in_f:
                        out_f.write(in_f.read())
                    # 删除处理过的分片
                    os.remove(chunk_path)
            
            logger.info(f'文件合并成功: {output_file}')
            return output_file
            
        except Exception as e:
            logger.error(f'文件合并失败: {str(e)}')
            raise
    
    def generate_unique_filename(self, original_filename):
        """生成唯一文件名
        
        Args:
            original_filename (str): 原始文件名
            
        Returns:
            str: 唯一文件名
        """
        file_extension = os.path.splitext(original_filename)[1]
        unique_name = f"{uuid.uuid4()}{file_extension}"
        return unique_name
    
    def get_file_info(self, file_path):
        """获取文件信息
        
        Args:
            file_path (str): 文件路径
            
        Returns:
            dict: 文件信息
        """
        if not os.path.exists(file_path):
            raise FileNotFoundError(f'文件不存在: {file_path}')
        
        return {
            'path': file_path,
            'size': os.path.getsize(file_path),
            'name': os.path.basename(file_path),
            'extension': os.path.splitext(file_path)[1],
            'created_at': os.path.getctime(file_path),
            'modified_at': os.path.getmtime(file_path)
        }
    
    def delete_file(self, file_path):
        """删除文件
        
        Args:
            file_path (str): 文件路径
        """
        try:
            if os.path.exists(file_path):
                os.remove(file_path)
                logger.info(f'成功删除文件: {file_path}')
        except Exception as e:
            logger.error(f'删除文件失败: {str(e)}')
            raise
    
    def get_file_url(self, file_path, base_url='http://localhost:8000'):
        """生成文件URL
        
        Args:
            file_path (str): 文件路径
            base_url (str): 基础URL
            
        Returns:
            str: 文件URL
        """
        # 获取相对于项目根目录的路径
        relative_path = os.path.relpath(file_path, '/')
        file_url = f"{base_url}/{relative_path}"
        return file_url
