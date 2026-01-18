from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel
import os
import uuid
import shutil
from pathlib import Path
from typing import List
import asyncio

# 初始化FastAPI应用
app = FastAPI(
    title="AI Face Swap API",
    description="Local Demo for AI Face Swap Application",
    version="1.0.0"
)

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 在生产环境中应该限制为特定域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 创建必要的目录
UPLOAD_DIR = Path("uploads")
OUTPUT_DIR = Path("outputs")
TASKS_DIR = Path("tasks")

UPLOAD_DIR.mkdir(exist_ok=True)
OUTPUT_DIR.mkdir(exist_ok=True)
TASKS_DIR.mkdir(exist_ok=True)

# 模拟任务数据库
tasks = {}

# 模型定义
class UserLogin(BaseModel):
    email: str
    password: str

class UserRegister(BaseModel):
    email: str
    password: str
    username: str

class Task(BaseModel):
    task_id: str
    status: str
    progress: int
    message: str
    result_url: str = ""

class ProcessVideoRequest(BaseModel):
    image_url: str
    video_url: str
    user_id: str

# 路由定义

# 健康检查
@app.get("/health")
async def health_check():
    return {"status": "ok", "message": "AI Face Swap API is running"}

# 认证路由
@app.post("/api/auth/login")
async def login(user: UserLogin):
    # 模拟登录
    return {
        "token": "mock-token-" + user.email,
        "user": {
            "id": "user-123",
            "email": user.email,
            "username": user.email.split("@")[0],
            "created_at": "2026-01-07T00:00:00Z"
        }
    }

@app.post("/api/auth/register")
async def register(user: UserRegister):
    # 模拟注册
    return {
        "token": "mock-token-" + user.email,
        "user": {
            "id": "user-" + str(uuid.uuid4()),
            "email": user.email,
            "username": user.username,
            "created_at": "2026-01-07T00:00:00Z"
        }
    }

# 任务路由
@app.get("/api/tasks")
async def get_tasks(user_id: str = Form(...)):
    # 模拟获取任务列表
    user_tasks = [task for task in tasks.values() if task.get("user_id") == user_id]
    return {"tasks": user_tasks}

@app.get("/api/tasks/{task_id}")
async def get_task(task_id: str):
    if task_id not in tasks:
        raise HTTPException(status_code=404, detail="Task not found")
    return {"task": tasks[task_id]}

# 文件上传路由
@app.post("/api/upload")
async def upload_file(
    file: UploadFile = File(...),
    file_type: str = Form(...),  # "image" or "video"
    user_id: str = Form(...)
):
    # 生成唯一文件名
    unique_id = str(uuid.uuid4())
    file_ext = os.path.splitext(file.filename)[1]
    file_path = UPLOAD_DIR / f"{file_type}-{unique_id}{file_ext}"
    
    print(f"Upload directory: {UPLOAD_DIR}")
    print(f"File path: {file_path}")

    try:
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        print("File saved successfully.")
    except Exception as e:
        print(f"Error saving file: {e}")
        return None
    
    # 返回文件URL
    file_url = f"/uploads/{file_path.name}"
    return {
        "url": file_url,
        "filename": file_path.name,
        "size": file_path.stat().st_size,
        "type": file_type
    }

# 处理视频路由
@app.post("/api/tasks")
async def create_task(request: ProcessVideoRequest):
    # 生成任务ID
    task_id = "task-" + str(uuid.uuid4())
    
    # 创建任务
    tasks[task_id] = {
        "task_id": task_id,
        "user_id": request.user_id,
        "image_url": request.image_url,
        "video_url": request.video_url,
        "status": "pending",
        "progress": 0,
        "created_at": "2026-01-07T00:00:00Z",
        "result_url": ""
    }
    
    # 模拟异步处理任务
    asyncio.create_task(process_task(task_id))
    
    return {"task": tasks[task_id]}

# 模拟视频处理
async def process_task(task_id):
    # 更新任务状态为processing
    tasks[task_id]["status"] = "processing"
    
    # 模拟处理进度
    for i in range(0, 101, 10):
        tasks[task_id]["progress"] = i
        tasks[task_id]["message"] = f"Processing... {i}%"
        await asyncio.sleep(1)  # 模拟处理时间
    
    # 处理完成，生成模拟结果
    result_filename = f"output-{task_id}.mp4"
    result_path = OUTPUT_DIR / result_filename
    
    # 模拟生成结果文件（创建一个空文件）
    result_path.touch()
    
    # 更新任务状态为completed
    tasks[task_id].update({
        "status": "completed",
        "progress": 100,
        "message": "Task completed successfully",
        "result_url": f"/outputs/{result_filename}"
    })

# 静态文件服务
@app.get("/uploads/{filename}")
async def serve_upload(filename: str):
    file_path = UPLOAD_DIR / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="File not found")
    return FileResponse(file_path)

@app.get("/outputs/{filename}")
async def serve_output(filename: str):
    file_path = OUTPUT_DIR / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="File not found")
    return FileResponse(file_path)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
