import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> showCupertinoNameEditModal(
    BuildContext context, String currentName, Function(String) onNameChanged) {
  TextEditingController controller = TextEditingController(text: currentName);

  return showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text("카테고리 이름 변경"),
        content: Column(
          children: [
            const SizedBox(height: 10),
            CupertinoTextField(
              controller: controller,
              maxLength: 20,
              placeholder: "이름 입력",
              textAlign: TextAlign.center,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
              suffix: GestureDetector(
                onTap: () => controller.clear(),
                child: const Icon(
                  Icons.cancel,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("취소"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child:
                const Text("저장", style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              onNameChanged(controller.text);
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
