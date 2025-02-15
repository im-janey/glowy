import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ColorAsset {
  final String imageUrl;
  final Color backgroundColor;
  final double rotation;

  ColorAsset({
    required this.imageUrl,
    required this.backgroundColor,
    required this.rotation,
  });
}

class ColorAssetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ColorAsset> fetchColorAsset(String colorName) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('colors').doc(colorName).get();

      if (!doc.exists) {
        throw Exception('Color not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      return ColorAsset(
        imageUrl: data['imageUrl'],
        backgroundColor: Color(int.parse("0xFF${data['hexColor']}"))
            .withOpacity(data['opacity'] ?? 1.0),
        rotation: -((data['rotation']) ?? 0.0),
      );
    } catch (e) {
      throw Exception('Error fetching color asset: $e');
    }
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String color;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<ColorAsset>(
      future: ColorAssetService().fetchColorAsset(color),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final colorAsset = snapshot.data!;

        return GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 55,
                height: 67,
                decoration: BoxDecoration(
                  color: colorAsset.backgroundColor,
                  border: Border.all(
                    color: isSelected
                        ? Colors.black
                        : (isDarkMode ? Colors.white54 : Colors.grey),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Transform.rotate(
                    angle: colorAsset.rotation * 3.1415926535 / 180,
                    child: Image.network(
                      colorAsset.imageUrl,
                      width: 33,
                      height: 33,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.black
                      : (isDarkMode ? Colors.white54 : Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String title;
  final String color;

  const ActivityCard({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ColorAsset>(
      future: ColorAssetService().fetchColorAsset(color),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final colorAsset = snapshot.data!;

        return Container(
          width: 154,
          height: 199,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorAsset.backgroundColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: colorAsset.rotation * 3.1415926535 / 180,
                child: Image.network(
                  colorAsset.imageUrl,
                  width: 87,
                  height: 87,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ActivityList extends StatelessWidget {
  final String date;
  final String title;
  final String color;

  const ActivityList({
    super.key,
    required this.date,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ColorAsset>(
      future: ColorAssetService().fetchColorAsset(color),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final colorAsset = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 13.0,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(
                    color: colorAsset.backgroundColor.withOpacity(0.8),
                    width: 1.5,
                  ),
                ),
                color: colorAsset.backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
