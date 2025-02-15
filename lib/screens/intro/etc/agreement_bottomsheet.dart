// ignore: file_names
import 'package:flutter/material.dart';

import '../signup.dart';

class AgreementBottomSheet extends StatefulWidget {
  const AgreementBottomSheet({super.key});

  @override
  _AgreementBottomSheetState createState() => _AgreementBottomSheetState();
}

class _AgreementBottomSheetState extends State<AgreementBottomSheet> {
  final List<bool> _isSelected = [false, false, false];

  void _toggleSelection(int index) {
    setState(() {
      _isSelected[index] = !_isSelected[index];
    });
  }

  bool _isAllSelected() {
    return _isSelected.every((element) => element == true);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.35,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (_, controller) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.01),
              Center(
                child: Container(
                  width: width * 0.1,
                  height: height * 0.005,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              const Center(
                child: Text(
                  '서비스 이용 필수 동의',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontFamily: 'Pretendard Variable',
                    fontWeight: FontWeight.w500,
                    height: 1.29,
                    letterSpacing: -0.30,
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              _buildAgreementItem(0, "이용 약관 동의"),
              _buildAgreementItem(1, "개인정보 보호정책 동의"),
              _buildAgreementItem(2, "데이터 저장 및 처리 동의"),
              const Spacer(),
              Center(
                child: SizedBox(
                  child: ElevatedButton(
                    onPressed: _isAllSelected()
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.28,
                        vertical: height * 0.02,
                      ),
                      backgroundColor: _isAllSelected()
                          ? const Color(0xFF33568C)
                          : const Color(0xFFCACACA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text(
                      "네, 모두 동의해요",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAgreementItem(int index, String title) {
    final width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () => _toggleSelection(index),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: width * 0.02),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: _isSelected[index]
                  ? const Color(0xFF38598F)
                  : const Color(0xFFCACACA),
            ),
            SizedBox(width: width * 0.02),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF445E86),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
