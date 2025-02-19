import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../provider/category_provider.dart';
import 'chatBot.dart';
import 'chatFree.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  // 기본값은 '카테고리 선택'
  String dropdownValue = '카테고리 선택';
  List<bool> isSelected = [true, false, false];

  // categories 리스트에는 실제 선택 가능한 항목들만 있음
  List<String> categories = ['운동', '공부', '취미'];
  TextEditingController categoryController = TextEditingController();
  TextEditingController activityController = TextEditingController();

  // 캘린더 관련 상태
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedStartDay;
  DateTime? _selectedEndDay;
  bool _isStartDatePickerOpen = false;
  bool _isEndDatePickerOpen = false;

  // 챗봇과 자유롭게 쓰기 선택 상태
  bool _isChatbotSelected = true;
  bool _isFreeWriteSelected = false;

  // 현재 선택된 단계를 반환하는 변수
  String get selectedStage {
    if (isSelected[0]) return 'start';
    if (isSelected[1]) return 'middle';
    if (isSelected[2]) return 'finish';
    return 'start'; // 기본값
  }

  // 모든 필수 정보가 입력되었는지 확인
  bool get _isAllFieldsFilled {
    return dropdownValue != '카테고리 선택' &&
        _selectedStartDay != null &&
        _selectedEndDay != null &&
        activityController.text.isNotEmpty;
  }

  // 카테고리 추가 로직 추가
  void _addCategory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: 340,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 팝업 제목
                const Text(
                  '새 카테고리 추가',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Pretendard Variable',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF121212),
                  ),
                ),
                const SizedBox(height: 16),
                // 텍스트필드 스타일 (활동 기본 정보 입력과 동일)
                Container(
                  width: double.infinity,
                  height: 43,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFBABABA)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        hintText: '카테고리 이름',
                        hintStyle: TextStyle(
                          color: Color(0xFF121212),
                          fontSize: 14,
                          fontFamily: 'Pretendard Variable',
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          fontFamily: 'Pretendard Variable',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF424248),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 추가 버튼
                    TextButton(
                      onPressed: () {
                        setState(() {
                          categories.add(categoryController.text);
                          // 새 카테고리 추가 시 dropdownValue도 해당 값으로 변경
                          dropdownValue = categoryController.text;
                        });
                        categoryController.clear();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        '추가',
                        style: TextStyle(
                          fontFamily: 'Pretendard Variable',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF33568C),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStartDatePicker() {
    setState(() {
      _isStartDatePickerOpen = !_isStartDatePickerOpen;
      _isEndDatePickerOpen = false; // 종료일 선택기는 닫기
    });
  }

  void _showEndDatePicker() {
    setState(() {
      _isEndDatePickerOpen = !_isEndDatePickerOpen;
      _isStartDatePickerOpen = false; // 시작일 선택기는 닫기
    });
  }

  void _closeDatePicker() {
    setState(() {
      _isStartDatePickerOpen = false;
      _isEndDatePickerOpen = false;
    });
  }

  void _showIncompleteFieldsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // 타이틀에 IconButton과 텍스트를 Row로 배치
          title: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  size: 35,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              // 중앙에 타이틀 텍스트 배치
              const Expanded(
                child: Text(
                  '알림',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 35),
            ],
          ),
          content: const Text('모든 필수 정보를 입력해주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (!_isAllFieldsFilled) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              width: 340,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // AppBar와 동일하게 좌측 패딩 16 적용
                      IconButton(
                        padding: const EdgeInsets.only(left: 16),
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.chevron_left,
                          size: 35,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 35),
                          child: const Text(
                            '알림',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '작성을 취소하시겠습니까?',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Pretendard Variable',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF121212),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          '아니오',
                          style: TextStyle(
                            fontFamily: 'Pretendard Variable',
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF424248),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          '예',
                          style: TextStyle(
                            fontFamily: 'Pretendard Variable',
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF33568C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
      return shouldPop ?? false;
    }
    return true;
  }

  // =====================
  // 커스텀 드롭다운 관련 메서드
  // =====================
  void _showCustomDropdown() {
    // 실제 선택 가능한 항목은 categories 리스트에 있으며 마지막에 '새 카테고리 추가' 항목을 추가합니다.
    List<String> dropdownItems = List<String>.from(categories);
    dropdownItems.add('새 카테고리 추가');

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: 340,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.46),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12, // 수평 간격
              runSpacing: 10, // 줄 바꿈 시 수직 간격
              children: dropdownItems
                  .map((item) => _buildCategoryItem(item))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(String item) {
    return GestureDetector(
      onTap: () {
        if (item == '새 카테고리 추가') {
          Navigator.pop(context);
          _addCategory();
        } else {
          setState(() {
            dropdownValue = item;
          });
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: item == '새 카테고리 추가'
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: Color(0xFF424248)),
                    SizedBox(width: 8),
                    Text(
                      '새 카테고리 추가',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF424248),
                      ),
                    ),
                  ],
                )
              : Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF121212),
                  ),
                ),
        ),
      ),
    );
  }
  // =====================

  @override
  void initState() {
    super.initState();
    // Firestore에서 카테고리 불러오기 (UID는 예제로 넣어둠, 실제 사용 시 수정 필요)
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.fetchCategories('uid');
    categoryProvider
        .fetchCategories(FirebaseAuth.instance.currentUser?.uid ?? '');
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '내 기록 추가',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: textColor),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDarkMode
                      ? [Colors.black, Colors.black87, Colors.black]
                      : [const Color(0xCCFFFFFF), Colors.white, Colors.white],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // 활동 기본 정보 입력
                    Text(
                      '활동 기본 정보 입력',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 43,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isDarkMode
                                ? Colors.grey[600]!
                                : const Color(0xFFBABABA)),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: activityController,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: '활동 이름을 입력하세요',
                            hintStyle: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    // ★ 기존 DropdownButtonFormField 대신 커스텀 드롭다운 위젯 사용
                    GestureDetector(
                      onTap: _showCustomDropdown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: isDarkMode
                                  ? Colors.grey[600]!
                                  : const Color(0xFFBABABA)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dropdownValue,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: textColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 활동 시작 및 종료일
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showStartDatePicker,
                            icon: Icon(Icons.calendar_today,
                                size: 16, color: textColor),
                            label: Text(
                              _selectedStartDay == null
                                  ? '활동 시작일'
                                  : '${_selectedStartDay!.year}/${_selectedStartDay!.month}/${_selectedStartDay!.day}',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isDarkMode ? Colors.grey[800] : Colors.white,
                              foregroundColor: textColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: isDarkMode
                                        ? Colors.grey[600]!
                                        : const Color(0xFFBABABA)),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showEndDatePicker,
                            icon: Icon(Icons.calendar_today,
                                size: 16, color: textColor),
                            label: Text(
                              _selectedEndDay == null
                                  ? '활동 종료일'
                                  : '${_selectedEndDay!.year}/${_selectedEndDay!.month}/${_selectedEndDay!.day}',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isDarkMode ? Colors.grey[800] : Colors.white,
                              foregroundColor: textColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: isDarkMode
                                        ? Colors.grey[600]!
                                        : const Color(0xFFBABABA)),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 활동 진행 단계
                    Text(
                      '활동 진행 단계 선택',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                        width: double.infinity,
                        height: 43,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey[600]!
                                : const Color(0xFFBABABA),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isSelected = [true, false, false];
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected[0]
                                      ? (isDarkMode
                                          ? Colors.blueGrey[700]
                                          : const Color(0xFF33568C))
                                      : (isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.white),
                                  foregroundColor: isSelected[0]
                                      ? Colors.white
                                      : (isDarkMode
                                          ? Colors.white70
                                          : const Color(0xFF424248)),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                    ),
                                  ),
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  '시작단계',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isSelected = [false, true, false];
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected[1]
                                      ? (isDarkMode
                                          ? Colors.blueGrey[700]
                                          : const Color(0xFF33568C))
                                      : (isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.white),
                                  foregroundColor: isSelected[1]
                                      ? Colors.white
                                      : (isDarkMode
                                          ? Colors.white70
                                          : const Color(0xFF424248)),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  '진행 중',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isSelected = [false, false, true];
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected[2]
                                      ? (isDarkMode
                                          ? Colors.blueGrey[700]
                                          : const Color(0xFF33568C))
                                      : (isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.white),
                                  foregroundColor: isSelected[2]
                                      ? Colors.white
                                      : (isDarkMode
                                          ? Colors.white70
                                          : const Color(0xFF424248)),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                    ),
                                  ),
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  '진행 완료',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                    const SizedBox(height: 24),
                    // 활동 기록 작성
                    Text(
                      '활동 기록 작성',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isChatbotSelected = true;
                                _isFreeWriteSelected = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isChatbotSelected
                                  ? (isDarkMode
                                      ? Colors.blueGrey[700]
                                      : const Color(0xFF33568C))
                                  : (isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white),
                              foregroundColor: _isChatbotSelected
                                  ? Colors.white
                                  : (isDarkMode
                                      ? Colors.white70
                                      : const Color(0xFF424248)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey[600]!
                                      : const Color(0xFFBABABA),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              '챗봇',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isChatbotSelected = false;
                                _isFreeWriteSelected = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFreeWriteSelected
                                  ? (isDarkMode
                                      ? Colors.blueGrey[700]
                                      : const Color(0xFF33568C))
                                  : (isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white),
                              foregroundColor: _isFreeWriteSelected
                                  ? Colors.white
                                  : (isDarkMode
                                      ? Colors.white70
                                      : const Color(0xFF424248)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey[600]!
                                      : const Color(0xFFBABABA),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              '자유롭게 쓰기',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Divider(),
                    // 기록 시작하기
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                      child: GestureDetector(
                        onTap: _isAllFieldsFilled
                            ? () {
                                if (_isChatbotSelected) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatBotPage(
                                        activityName: activityController.text,
                                        category: dropdownValue,
                                        startDate: _selectedStartDay!,
                                        endDate: _selectedEndDay!,
                                        stage: selectedStage,
                                      ),
                                    ),
                                  );
                                } else if (_isFreeWriteSelected) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatFreePage(
                                        activityName: activityController.text,
                                        category: dropdownValue,
                                        startDate: _selectedStartDay!,
                                        endDate: _selectedEndDay!,
                                        stage: selectedStage,
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _isAllFieldsFilled
                                ? (isDarkMode
                                    ? Colors.blueGrey[700]
                                    : const Color(0xFF33568C))
                                : (isDarkMode
                                    ? Colors.grey[600]
                                    : const Color(0xFFC4C4C4)),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              '기록 시작하기',
                              style: TextStyle(
                                color: _isAllFieldsFilled
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 활동 날짜 선택하는 달력
            if (_isStartDatePickerOpen || _isEndDatePickerOpen)
              Positioned(
                top: 200,
                left: 16,
                right: 16,
                child: Material(
                  elevation: 4,
                  child: Column(
                    children: [
                      // 달력
                      TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Month'
                        },
                        headerStyle: HeaderStyle(
                          titleTextStyle: TextStyle(color: textColor),
                          formatButtonTextStyle: TextStyle(color: textColor),
                          leftChevronIcon:
                              Icon(Icons.chevron_left, color: textColor),
                          rightChevronIcon:
                              Icon(Icons.chevron_right, color: textColor),
                        ),
                        calendarStyle: CalendarStyle(
                          todayTextStyle: TextStyle(color: textColor),
                          defaultTextStyle: TextStyle(color: textColor),
                          weekendTextStyle: TextStyle(color: textColor),
                          outsideTextStyle:
                              TextStyle(color: textColor.withOpacity(0.5)),
                          disabledTextStyle:
                              TextStyle(color: textColor.withOpacity(0.3)),
                        ),
                        selectedDayPredicate: (day) {
                          return isSameDay(
                            _isStartDatePickerOpen
                                ? _selectedStartDay
                                : _selectedEndDay,
                            day,
                          );
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                            if (_isStartDatePickerOpen) {
                              _selectedStartDay = selectedDay;
                            } else if (_isEndDatePickerOpen) {
                              _selectedEndDay = selectedDay;
                            }
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() {});
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                      ),
                      // ok 버튼
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _closeDatePicker,
                          child: Text(
                            'OK',
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
