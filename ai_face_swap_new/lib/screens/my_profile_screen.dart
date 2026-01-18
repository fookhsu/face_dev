import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/task_provider.dart';
import '../styles/app_theme.dart';

// 个人页面
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  File? _sourceImage;
  List<Map<String, dynamic>> _creations = [];
  bool _isUploading = false;
  String _uploadStatus = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 在Widget构建完成后再加载creations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCreations();
    });
  }

  Future<void> _loadCreations() async {
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.fetchTasks();
      setState(() {
        _creations = taskProvider.tasks;
      });
    } catch (e) {
      print('Error loading creations: $e');
    }
  }

  Future<void> _pickSourceImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      // 平台特定处理
      if (false) {
        // Web平台处理
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _sourceImage = File(pickedFile.path);
            _uploadStatus = 'Source image selected: ${pickedFile.path.split('/').last}';
          });
          // 自动上传
          await _uploadSourceImage();
        }
      } else {
        // 移动平台和桌面平台处理
        final pickedFile = await picker.pickImage(source: source);
        if (pickedFile != null) {
          setState(() {
            _sourceImage = File(pickedFile.path);
            _uploadStatus = 'Source image selected: ${pickedFile.path.split('/').last}';
          });
          // 自动上传
          await _uploadSourceImage();
        }
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error picking image: $e';
      });
    }
  }

  Future<void> _uploadSourceImage() async {
    if (_sourceImage == null) return;

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Uploading source image...';
    });

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final result = await taskProvider.uploadFile(
        _sourceImage!.path,
        'image'
      );

      // 立即添加到creations列表
      setState(() {
        _creations.add({
          'id': 'temp-${DateTime.now().millisecondsSinceEpoch}',
          'url': result['url'],
          'filename': result['filename'],
          'status': 'uploaded',
          'created_at': DateTime.now().toIso8601String(),
        });
        _uploadStatus = 'Source image uploaded successfully!';
        _isUploading = false;
      });

      // 显示成功消息
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Source image uploaded successfully!')),
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

  Future<void> _submitToBackend() async {
    if (_creations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No videos uploaded yet!')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 这里可以选择最近上传的视频作为source和target
      // 为了演示，我们假设第一个是source，最后一个是target
      if (_creations.length >= 2) {
        final sourceCreation = _creations.first;
        final targetCreation = _creations.last;

        // 发送请求到后端
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        final task = await taskProvider.createTask(
          sourceCreation['result_url'] ?? sourceCreation['url'],
          targetCreation['result_url'] ?? targetCreation['url']
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task submitted successfully! Task ID: ${task['id']}')),
          );
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Need at least 2 videos to process!')),
          );
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color.fromARGB(255, 15, 15, 20),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // 背景渐变
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息
                Row(
                  children: [
                    // 用户头像
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 100, 50, 200),
                            Color.fromARGB(255, 200, 50, 255),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.pets,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 用户ID
                    const Text(
                      '5387218',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // 解锁所有功能横幅
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 150, 50, 255),
                        Color.fromARGB(255, 255, 50, 150),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Unlock all features!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Enjoy 50% off on Magic',
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 50, 150, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Get Pro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Creations 和 Favorites 按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromARGB(255, 50, 50, 70),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Creations',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${_creations.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromARGB(255, 50, 50, 70),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Favorites',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Creations 列表
                if (_creations.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Recent Creations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _creations.length,
                          itemBuilder: (context, index) {
                            final creation = _creations[index];
                            return Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color.fromARGB(255, 40, 40, 60),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        color: const Color.fromARGB(255, 60, 60, 80),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          creation['type'] == 'image' ? Icons.image : Icons.video_file,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      creation['filename'] ?? 'Media ${index + 1}',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitToBackend,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 150, 50, 255),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Submit for Processing',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 24),
                
                // Faces 标题
                const Text(
                  'Faces',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Faces 列表
                Row(
                  children: [
                    // 添加人脸按钮
                    GestureDetector(
                      onTap: () {
                        // 打开相册选择source图片
                        _pickSourceImage(ImageSource.gallery);
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color.fromARGB(255, 50, 50, 70),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 人脸1
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color.fromARGB(255, 60, 60, 80),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 人脸2
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color.fromARGB(255, 60, 60, 80),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // 上传状态
                if (_uploadStatus.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isUploading
                          ? const Color.fromARGB(255, 50, 50, 100)
                          : _uploadStatus.contains('successfully')
                              ? const Color.fromARGB(255, 20, 80, 20)
                              : const Color.fromARGB(255, 80, 20, 20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _uploadStatus,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // My Assets 标题
                const Text(
                  'My Assets',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Energy
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromARGB(255, 50, 50, 70),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'Energy:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.bolt,
                            color: Colors.yellow,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '5',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 50, 50, 100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Buy',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Magic
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromARGB(255, 50, 50, 70),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'Magic:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.star,
                            color: Colors.purple,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '2',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 150, 50, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Buy',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
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
          if (index == 2) {
            // 导航到AI Studio页面
            Navigator.pushNamed(context, '/');
          }
        },
      ),
    );
  }
}
