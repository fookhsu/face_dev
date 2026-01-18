import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:io' show Platform;
import '../providers/task_provider.dart';
import '../styles/app_theme.dart';

// String extension for capitalize
extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

// AI Studio 页面
class AIStudioScreen extends StatefulWidget {
  const AIStudioScreen({super.key});

  @override
  State<AIStudioScreen> createState() => _AIStudioScreenState();
}

class _AIStudioScreenState extends State<AIStudioScreen> {
  File? _targetVideo;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  Future<void> _pickMedia(ImageSource source) async {
    final picker = ImagePicker();
    try {
      print('DEBUG: _pickMedia called with source: $source');
      print('DEBUG: Current platform: ${Platform.operatingSystem}');
      
      // 显示选择对话框
      print('DEBUG: Showing media type dialog');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select Media Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Image'),
                onTap: () async {
                  print('DEBUG: Image selected from dialog');
                  Navigator.pop(context);
                  
                  try {
                    // 平台特定处理
                    if (kIsWeb) {
                      // Web平台处理
                      print('DEBUG: Web platform detected, picking image from gallery');
                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        print('DEBUG: Image picked on web: ${pickedFile.path}');
                        setState(() {
                          _targetVideo = File(pickedFile.path);
                          _uploadStatus = 'Image selected: ${pickedFile.path.split('/').last}';
                        });
                        // 自动上传
                        print('DEBUG: Uploading image on web');
                        await _uploadTargetVideo('image');
                      } else {
                        print('DEBUG: No image selected on web');
                      }
                    } else {
                      // 移动平台和桌面平台处理
                      print('DEBUG: Non-web platform detected, picking image from $source');
                      final pickedFile = await picker.pickImage(source: source);
                      if (pickedFile != null) {
                        print('DEBUG: Image picked on ${Platform.operatingSystem}: ${pickedFile.path}');
                        setState(() {
                          _targetVideo = File(pickedFile.path);
                          _uploadStatus = 'Image selected: ${pickedFile.path.split('/').last}';
                        });
                        // 自动上传
                        print('DEBUG: Uploading image on ${Platform.operatingSystem}');
                        await _uploadTargetVideo('image');
                      } else {
                        print('DEBUG: No image selected on ${Platform.operatingSystem}');
                      }
                    }
                  } catch (e) {
                    print('DEBUG: Error picking image: $e');
                    setState(() {
                      _uploadStatus = 'Error picking image: $e';
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.video_file),
                title: Text('Video'),
                onTap: () async {
                  print('DEBUG: Video selected from dialog');
                  Navigator.pop(context);
                  
                  try {
                    // 平台特定处理
                    if (kIsWeb) {
                      // Web平台处理
                      print('DEBUG: Web platform detected, picking video from gallery');
                      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        print('DEBUG: Video picked on web: ${pickedFile.path}');
                        setState(() {
                          _targetVideo = File(pickedFile.path);
                          _uploadStatus = 'Video selected: ${pickedFile.path.split('/').last}';
                        });
                        // 自动上传
                        print('DEBUG: Uploading video on web');
                        await _uploadTargetVideo('video');
                      } else {
                        print('DEBUG: No video selected on web');
                      }
                    } else {
                      // 移动平台和桌面平台处理
                      print('DEBUG: Non-web platform detected, picking video from $source');
                      final pickedFile = await picker.pickVideo(source: source);
                      if (pickedFile != null) {
                        print('DEBUG: Video picked on ${Platform.operatingSystem}: ${pickedFile.path}');
                        setState(() {
                          _targetVideo = File(pickedFile.path);
                          _uploadStatus = 'Video selected: ${pickedFile.path.split('/').last}';
                        });
                        // 自动上传
                        print('DEBUG: Uploading video on ${Platform.operatingSystem}');
                        await _uploadTargetVideo('video');
                      } else {
                        print('DEBUG: No video selected on ${Platform.operatingSystem}');
                      }
                    }
                  } catch (e) {
                    print('DEBUG: Error picking video: $e');
                    setState(() {
                      _uploadStatus = 'Error picking video: $e';
                    });
                  }
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('DEBUG: Error in _pickMedia: $e');
      setState(() {
        _uploadStatus = 'Error picking media: $e';
      });
    }
  }

  Future<void> _uploadTargetVideo(String mediaType) async {
    if (_targetVideo == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Uploading target ${mediaType}...';
    });

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final result = await taskProvider.uploadFile(
        _targetVideo!.path,
        mediaType
      );

      setState(() {
        _uploadProgress = 100.0;
        _uploadStatus = 'Upload completed! ${mediaType.capitalize()} URL: ${result['url']}';
        _isUploading = false;
      });

      // 显示成功消息
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Target ${mediaType} uploaded successfully!')),
        );
      });
    } catch (e) {
      setState(() {
        _uploadStatus = 'Upload failed: $e';
        _isUploading = false;
      });

      // 显示错误消息
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DIY Swap'),
        backgroundColor: const Color.fromARGB(255, 15, 15, 20),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // 背景星空效果
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 15, 15, 20),
                    Color.fromARGB(255, 30, 20, 60),
                  ],
                ),
              ),
            ),
          ),
          // 主内容
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'AI Studio',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Click to upload your custom template',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 150, 150, 255),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 上传状态
                  if (_uploadStatus.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: _isUploading 
                            ? const Color.fromARGB(255, 50, 50, 100)
                            : _uploadStatus.contains('completed')
                                ? const Color.fromARGB(255, 20, 80, 20)
                                : const Color.fromARGB(255, 80, 20, 20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _uploadStatus,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          if (_isUploading)
                            Column(
                              children: [
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                  value: _uploadProgress / 100,
                                  backgroundColor: const Color.fromARGB(255, 100, 100, 150),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${_uploadProgress.toStringAsFixed(1)}%',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 30),
                  // 中央上传区域
                  GestureDetector(
                    onTap: () {
                      // 打开相册选择
                      _pickMedia(ImageSource.gallery);
                    },
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(255, 100, 50, 200),
                            Color.fromARGB(255, 200, 50, 255),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 发光圆环
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.8),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          // 上传图标或媒体预览
                          _targetVideo != null
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _targetVideo!.path.contains('.mp4') || _targetVideo!.path.contains('.mov')
                                          ? Icons.video_file
                                          : Icons.image,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _targetVideo!.path.split('/').last,
                                      style: const TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                )
                              : const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.upload,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Upload Target Media',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // 底部按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ElevatedButton(
                            onPressed: () {
                              // 相册选择逻辑
                              _pickMedia(ImageSource.gallery);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 50, 50, 70),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_album,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Album',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ElevatedButton(
                            onPressed: () {
                              // 相机拍摄逻辑
                              _pickMedia(ImageSource.camera);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 150, 50, 255),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Camera',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // 添加一些底部间距
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 25, 25, 35),
        selectedItemColor: const Color.fromARGB(255, 150, 50, 255),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'AI Video',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.palette),
            label: 'Style',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'AI Studio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Profile',
          ),
        ],
        onTap: (index) {
          // 底部导航逻辑
          if (index == 4) {
            // 导航到个人页面
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
