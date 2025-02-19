import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart'; // FilePicker 추가
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'free_chips.dart';
import 'recommend.dart';

class ChatFreePage extends StatefulWidget {
  final String activityName;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final String stage;

  const ChatFreePage({
    Key? key,
    required this.activityName,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.stage,
  }) : super(key: key);

  @override
  _ChatFreePageState createState() => _ChatFreePageState();
}

class _ChatFreePageState extends State<ChatFreePage> {
  bool _showMenu = false;
  List<Map<String, dynamic>> _contentList = [];
  Set<int> _selectedIndices = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // 최초 텍스트 입력 항목 추가 (기본 한 개)
    _contentList.add({
      "type": "text",
      "controller": TextEditingController(),
      "focusNode": FocusNode(),
      "listenerAdded": false,
    });
  }

  // 질문 + 답변 텍스트필드를 한 쌍으로 추가
  void _addQuestionItem(Map<String, dynamic> result) {
    final questionId = DateTime.now().microsecondsSinceEpoch;

    // 질문 항목 추가
    _contentList.add({
      "type": "question",
      "content": result['content'],
      "stage": result['stage'],
      "index": result['index'],
      "questionId": questionId,
    });

    // 해당 질문에 연결된 답변 텍스트필드 항목 추가
    _contentList.add({
      "type": "text",
      "controller": TextEditingController(),
      "focusNode": FocusNode(),
      "linkedQuestionId": questionId,
      "listenerAdded": false,
    });
  }

  // 이미지(앨범) 선택 후 이미지 항목 추가
  void _navigateToAlbum() async {
    setState(() => _showMenu = false);
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final questionId = DateTime.now().microsecondsSinceEpoch;
        setState(() {
          _contentList.add({
            "type": "image",
            "localPath": image.path,
            "fileName": image.name,
            "questionId": questionId,
          });
          // 이미지와 함께 보여줄 설명 혹은 캡션을 입력할 수 있는 텍스트필드 추가
          _contentList.add({
            "type": "text",
            "controller": TextEditingController(),
            "focusNode": FocusNode(),
            "linkedQuestionId": questionId,
            "listenerAdded": false,
          });
        });
      }
    } catch (e) {
      print("이미지 선택 중 오류 발생: $e");
      // 필요에 따라 사용자에게 에러 메시지를 보여줄 수 있습니다.
    }
  }

  // 질문 추천 페이지로 이동
  void _navigateToRecommendPage() async {
    setState(() => _showMenu = false);
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(builder: (context) => const RecommendPage()),
    );
    if (result != null) {
      // result가 {"type": "skill", "content": "소통 능력"} 형태로 넘어온다면
      if (result['type'] == 'skill') {
        final questionId = DateTime.now().microsecondsSinceEpoch;
        setState(() {
          _contentList.add({
            "type": "skill",
            "content": result['content'],
            "questionId": questionId,
          });
          _contentList.add({
            "type": "text",
            "controller": TextEditingController(),
            "focusNode": FocusNode(),
            "linkedQuestionId": questionId,
            "listenerAdded": false,
          });
        });
      } else {
        // 질문인 경우는 기존 로직
        setState(() => _addQuestionItem(result));
      }
    }
  }

  // 🏷 [새로 추가] 파일 선택 함수
  void _navigateToFilePicker() async {
    setState(() => _showMenu = false);

    try {
      // FilePicker 열기 (아무 파일이나 선택 가능)
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        final fileName = pickedFile.name; // 예: "myfile.pdf"
        final filePath = pickedFile.path; // 실제 경로
        final fileSize = _formatFileSize(pickedFile.size); // 예: "3.2MB"

        final questionId = DateTime.now().microsecondsSinceEpoch;

        setState(() {
          _contentList.add({
            "type": "file",
            "fileName": fileName,
            "filePath": filePath,
            "fileSize": fileSize,
            "questionId": questionId,
          });
        });
      }
    } catch (e) {
      print("파일 선택 오류: $e");
      // 필요하다면 에러 메시지 표시
    }
  }

  // [도움 함수] 파일 사이즈를 보기 좋게 포맷 (MB 단위)
  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes <= 0) return "0 B";
    final sizeInMB = sizeInBytes / (1024 * 1024);
    return "${sizeInMB.toStringAsFixed(1)}MB";
  }

  // "역량(스킬)" 선택 페이지
  void _navigateToFreeChips() async {
    setState(() => _showMenu = false);
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (context) => FreeChips()),
    );
    if (result != null) {
      final questionId = DateTime.now().microsecondsSinceEpoch;
      setState(() {
        _contentList.add({
          "type": "skill",
          "content": result,
          "questionId": questionId,
        });
        _contentList.add({
          "type": "text",
          "controller": TextEditingController(),
          "focusNode": FocusNode(),
          "linkedQuestionId": questionId,
          "listenerAdded": false,
        });
      });
    }
  }

  // 이미지 업로드
  Future<void> _uploadImages() async {
    for (var item in _contentList) {
      if (item['type'] == 'image' && item.containsKey('localPath')) {
        final localPath = item['localPath'];
        final file = File(localPath);
        final fileName = item['fileName'] ??
            'image_${DateTime.now().millisecondsSinceEpoch}';
        final ref = FirebaseStorage.instance
            .ref()
            .child('responses_images')
            .child(fileName);
        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        // 다운로드 URL로 content를 교체하고 임시 localPath는 제거
        item['content'] = downloadUrl;
        item.remove('localPath');
      }
    }
  }

  // Firestore 저장
  Future<void> _saveContentToFirestore() async {
    try {
      // 이미지 항목 있다면 먼저 업로드 처리
      await _uploadImages();

      List<Map<String, dynamic>> savedContent = _contentList.map((item) {
        final type = item['type'];
        if (type == 'text') {
          return {
            "type": "text",
            "content": item['controller'].text,
            if (item.containsKey('linkedQuestionId'))
              "linkedQuestionId": item['linkedQuestionId'],
          };
        } else if (type == 'question') {
          return {
            "type": "question",
            "content": item['content'],
            "stage": item['stage'] ?? '',
            "index": item['index'] ?? -1,
            if (item.containsKey('questionId'))
              "questionId": item['questionId'],
          };
        } else if (type == 'skill') {
          return {
            "type": "skill",
            "content": item['content'],
          };
        } else if (type == 'image') {
          return {
            "type": "image",
            "content": item['content'], // 다운로드 URL
          };
        }
        // (추가) 파일 항목을 Firestore에도 저장
        else if (type == 'file') {
          return {
            "type": "file",
            "fileName": item['fileName'],
            "fileSize": item['fileSize'],
            // filePath를 그대로 저장할지, 직접 업로드 후 downloadURL 저장할지 결정 가능
            // "filePath": item['filePath'],
          };
        }
        // 기타 항목
        else {
          return {
            "type": item['type'],
            "content": item['content'],
          };
        }
      }).toList();

      await _firestore.collection('responses').add({
        'title': widget.activityName,
        'category': widget.category,
        'startDate': widget.startDate,
        'endDate': widget.endDate,
        'stage': widget.stage,
        'mode': 'free',
        'timestamp': FieldValue.serverTimestamp(),
        'content': savedContent,
        'isFavorite': false,
      });

      print("✅ Firestore에 저장 완료");
      Navigator.of(context).pop();
    } catch (e) {
      print("❌ Firestore 저장 오류: $e");
    }
  }

  // 답변 여부 체크 (텍스트 입력 + 포커스 여부)
  bool _hasAnswer(int questionId) {
    try {
      final answerItem = _contentList.firstWhere((element) =>
          element['type'] == 'text' &&
          element['linkedQuestionId'] == questionId);
      final text = answerItem['controller'].text;
      final focusNode = answerItem['focusNode'] as FocusNode;
      return text.isNotEmpty && focusNode.hasFocus;
    } catch (e) {
      return false;
    }
  }

  // 질문/답변 쌍 제거
  void _removeQuestion(int questionId) {
    setState(() {
      _contentList.removeWhere((item) {
        final isQuestion =
            (item['type'] == 'question' && item['questionId'] == questionId);
        final isAnswer =
            (item['type'] == 'text' && item['linkedQuestionId'] == questionId);
        final isImage =
            (item['type'] == 'image' && item['questionId'] == questionId);
        final isFile =
            (item['type'] == 'file' && item['questionId'] == questionId);
        return isQuestion || isAnswer || isImage || isFile;
      });
    });
  }

  // 롱프레스 삭제 버튼
  Widget _buildDeleteButton(int index) {
    return Positioned(
      top: 4,
      right: 8,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _contentList.removeAt(index);
            if (index < _contentList.length &&
                _contentList[index]['type'] == 'text') {
              _contentList.removeAt(index);
            }
            _selectedIndices.remove(index);
          });
        },
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          padding: const EdgeInsets.all(4),
          child: const Icon(Icons.close, size: 16, color: Colors.white),
        ),
      ),
    );
  }

  // 질문 컨테이너
  Widget _buildQuestionContainer(Map<String, dynamic> item, int index) {
    final content = item['content'] ?? '';
    final int? questionId = item['questionId'];
    final bool answered = (questionId != null) ? _hasAnswer(questionId) : false;
    final textColor = const Color(0xFF365481);

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F1FB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (answered) ...[
                GestureDetector(
                  onTap: () => _removeQuestion(questionId!),
                  child: Text(
                    '× ',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              Expanded(
                child: Text(
                  content,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  softWrap: true,
                  maxLines: null,
                ),
              ),
            ],
          ),
        ),
        if (_selectedIndices.contains(index)) _buildDeleteButton(index),
      ],
    );
  }

  // 스킬(역량) 컨테이너
  Widget _buildSkillContainer(Map<String, dynamic> item, int index) {
    final content = item['content'] ?? '';
    final Color bgColor = const Color(0xFFD9F3FF);
    final Color textColor = const Color(0xFF0077B6);

    return GestureDetector(
      onLongPress: () {
        setState(() {
          if (_selectedIndices.contains(index)) {
            _selectedIndices.remove(index);
          } else {
            _selectedIndices.add(index);
          }
        });
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              content,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              softWrap: true,
              maxLines: null,
            ),
          ),
          if (_selectedIndices.contains(index)) _buildDeleteButton(index),
        ],
      ),
    );
  }

  // 일반 텍스트필드
  Widget _buildTextField(Map<String, dynamic> item, int index) {
    final controller = item['controller'] as TextEditingController;
    if (item['focusNode'] == null) {
      item['focusNode'] = FocusNode();
    }
    FocusNode focusNode = item['focusNode'] as FocusNode;

    if (!(item['listenerAdded'] as bool? ?? false)) {
      controller.addListener(() {
        setState(() {});
      });
      focusNode.addListener(() {
        setState(() {});
      });
      item['listenerAdded'] = true;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(
          hintText: '자유롭게 작성해보세요...',
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  // 이미지 컨테이너
  Widget _buildImagePreview(Map<String, dynamic> item) {
    if (item['type'] == 'image') {
      Widget imageWidget;

      if (item.containsKey('localPath')) {
        // 로컬 이미지
        imageWidget = Image.file(
          File(item['localPath']),
          fit: BoxFit.contain,
        );
      } else if (item.containsKey('content')) {
        // 네트워크 이미지
        imageWidget = Image.network(
          item['content'],
          fit: BoxFit.contain,
          // 로딩 중 표시
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          },
          // 에러 발생 시 표시
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Icon(Icons.error));
          },
        );
      } else {
        // 이미지 정보가 없으면 빈 위젯
        return const SizedBox.shrink();
      }

      return GestureDetector(
        onLongPress: () {
          // 삭제 확인 다이얼로그
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("이미지 삭제"),
              content: const Text("이 이미지를 삭제하시겠습니까?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      // 이미지와 연결된 텍스트필드 삭제
                      _removeQuestion(item['questionId']);
                    });
                  },
                  child: const Text("삭제"),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // 또는 Colors.transparent
              boxShadow: [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 10,
                  offset: const Offset(2, 2),
                ),
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: imageWidget,
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // 🏷 [추가] 파일 컨테이너
  Widget _buildFileContainer(Map<String, dynamic> item, int index) {
    final fileName = item['fileName'] ?? 'Unknown';
    final fileSize = item['fileSize'] ?? '';
    final bgColor = const Color(0xFFE7F1FB);
    final textColor = const Color(0xFF365481);

    return GestureDetector(
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding:
                const EdgeInsets.only(left: 16, right: 8, top: 1, bottom: 1),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(30),
            ),
            // 파일명 (크기) X 형태
            child: Row(
              children: [
                // 파일명 + 파일 크기
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: fileName,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (fileSize.isNotEmpty) ...[
                          const TextSpan(text: '  '),
                          TextSpan(
                            text: '($fileSize)',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 닫기(X) 버튼
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _contentList.removeAt(index);
                      _selectedIndices.remove(index);
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.close, color: Colors.black54, size: 20),
                  ),
                ),
              ],
            ),
          ),
          // 롱프레스 선택 시, 상단 우측에 빨간 X 표시를 추가하는 등 추가 로직
          if (_selectedIndices.contains(index)) _buildDeleteButton(index),
        ],
      ),
    );
  }

  // FAB 메뉴 아이템 위젯
  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            Icon(
              icon,
              color: const Color(0xFF365481),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // 빌드
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showMenu = false),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // 상단 AppBar
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 35),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        widget.activityName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Pretendard Variable',
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _saveContentToFirestore,
                      child: Container(
                        width: 55,
                        alignment: Alignment.center,
                        child: const Text(
                          '저장',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Pretendard Variable',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 본문: 컨텐츠 리스트
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _contentList.length,
                  itemBuilder: (context, index) {
                    final item = _contentList[index];
                    final type = item['type'];

                    if (type == 'question') {
                      return _buildQuestionContainer(item, index);
                    } else if (type == 'skill') {
                      return _buildSkillContainer(item, index);
                    } else if (type == 'text') {
                      return _buildTextField(item, index);
                    } else if (type == 'image') {
                      return _buildImagePreview(item);
                    } else if (type == 'file') {
                      return _buildFileContainer(item, index);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
        // FAB + 펼쳐지는 메뉴
        floatingActionButton: Stack(
          children: [
            if (_showMenu)
              Positioned(
                bottom: 80,
                right: 16,
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 187,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // "질문" 버튼 → RecommendPage
                        _buildMenuItem(
                          "질문",
                          Icons.contact_support_outlined,
                          _navigateToRecommendPage,
                        ),
                        const Divider(height: 1, color: Colors.grey),
                        // "앨범" 버튼 → 갤러리(이미지) 선택
                        _buildMenuItem(
                          "앨범",
                          Icons.photo_library_outlined,
                          _navigateToAlbum,
                        ),
                        const Divider(height: 1, color: Colors.grey),
                        // "파일" 버튼 → FilePicker
                        _buildMenuItem(
                          "파일",
                          Icons.attach_file,
                          _navigateToFilePicker,
                        ),
                        const Divider(height: 1, color: Colors.grey),
                        // "역량" 버튼 → FreeChips (스킬)
                        _buildMenuItem(
                          "역량",
                          Icons.code,
                          _navigateToFreeChips,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 20,
              right: 16,
              child: SizedBox(
                width: 50,
                height: 50,
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _showMenu = !_showMenu;
                    });
                  },
                  backgroundColor: const Color(0xFFE7F1FB),
                  foregroundColor: const Color(0xFF365481),
                  elevation: 0,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, size: 35),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
