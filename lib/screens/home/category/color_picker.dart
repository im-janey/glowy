import 'package:flutter/material.dart';

Future<Color?> showColorPicker(
    BuildContext context, Color selectedColor) async {
  return await showModalBottomSheet<Color>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    builder: (context) {
      return _ColorPickerBottomSheet(selectedColor: selectedColor);
    },
  );
}

class _ColorPickerBottomSheet extends StatefulWidget {
  final Color selectedColor;

  const _ColorPickerBottomSheet({required this.selectedColor});

  @override
  State<_ColorPickerBottomSheet> createState() =>
      _ColorPickerBottomSheetState();
}

class _ColorPickerBottomSheetState extends State<_ColorPickerBottomSheet> {
  late Color _selectedColor;

  /// 20가지 색상 (사진 속 순서대로 정렬하거나 원하는 순서대로 넣어주세요)
  final List<Color> _colorOptions = [
    // 첫 번째 줄(예: 블루 계열)
    const Color(0xFFEEF7FC),
    const Color(0xFFE0F1FF),
    const Color(0xFFD1EFFE),
    const Color(0xFFDAF8F9),
    const Color(0xFFC9DDFF),

    // 두 번째 줄(예: 퍼플 계열)
    const Color(0xFFF3F0FB),
    const Color(0xFFFAE5FE),
    const Color(0xFFEFD9FF),
    const Color(0xFFE2D5F1),
    const Color(0xFFE0E4FF),

    // 세 번째 줄(예: 그린 계열)
    const Color(0xFFE7FFEC),
    const Color(0xFFF8FDD6),
    const Color(0xFFE8FFC9),
    const Color(0xFFE5FFE5),
    const Color(0xFFCCEAD3),

    // 네 번째 줄(예: 레드/옅은 오렌지/베이지 계열)
    const Color(0xFFFFEEEE),
    const Color(0xFFFFE3E8),
    const Color(0xFFFFD1D6),
    const Color(0xFFFFD2C9),
    const Color(0xFFE9D3D4),

    const Color(0xFFFFF4CC),
    const Color(0xFFFFF1B0),
    const Color(0xFFFFE6C9),
    const Color(0xFFEDDCCD),
    const Color(0xFFDEDBE5),
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "색상",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          // GridView를 사용해 5열로 배치
          GridView.count(
            crossAxisCount: 5, // 한 줄에 5개씩
            mainAxisSpacing: 30, // 세로 간격
            crossAxisSpacing: 45, // 가로 간격
            shrinkWrap: true, // 그리드 높이를 자식 크기에 맞춤
            physics:
                const NeverScrollableScrollPhysics(), // BottomSheet 자체 스크롤과 충돌 방지
            children: _colorOptions.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                  Navigator.pop(context, color);
                },
                child: ColorOption(
                  color: color,
                  isSelected: _selectedColor == color,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;

  const ColorOption({super.key, required this.color, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 31,
      height: 31,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: isSelected
            ? Border.all(color: Colors.grey.shade700, width: 2.0)
            : null,
      ),
    );
  }
}
