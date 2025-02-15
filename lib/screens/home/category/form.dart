import 'package:flutter/material.dart';

import 'color_picker.dart';
import 'name_modal.dart';

/// 공통으로 사용할 CategoryForm 위젯
class CategoryForm extends StatefulWidget {
  final String initialName;
  final Color initialColor;
  final bool isEditing;
  final void Function(String newName, Color newColor) onSave;
  final VoidCallback? onDelete;

  const CategoryForm({
    super.key,
    required this.initialName,
    required this.initialColor,
    required this.isEditing,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  late String _name;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _selectedColor = widget.initialColor;
  }

  void _editName() {
    showCupertinoNameEditModal(context, _name, (newName) {
      setState(() {
        _name = newName;
      });
    });
  }

  Future<void> _pickColor() async {
    final pickedColor = await showColorPicker(context, _selectedColor);
    if (pickedColor != null) {
      setState(() {
        _selectedColor = pickedColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _editName,
          child: Column(
            children: [
              Container(
                width: 67,
                height: 82,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.add, size: 40, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _name,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.edit, size: 16, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // 색상 선택
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("색상", style: TextStyle(fontSize: 16)),
            GestureDetector(
              onTap: _pickColor,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
        const Divider(),

        const SizedBox(height: 20),

        // 삭제 버튼 (수정 모드에서만 표시)
        if (widget.isEditing)
          TextButton(
            onPressed: widget.onDelete,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "삭제",
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
