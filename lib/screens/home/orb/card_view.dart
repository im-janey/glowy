import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/activity_provider.dart';
import '../widgets.dart';

class CustomCardView extends StatefulWidget {
  const CustomCardView({super.key});

  @override
  State<CustomCardView> createState() => _CustomCardViewState();
}

class _CustomCardViewState extends State<CustomCardView> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Consumer<ActivityProvider>(
      builder: (context, categoryProvider, child) {
        final activities = categoryProvider.activities;

        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/initiate.png'),
                const SizedBox(height: 60),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.8,
          ),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            final title = activity['title'] ?? '기본 제목';
            final color = activity['color'] ?? 'grey';

            return Align(
              alignment: Alignment.center,
              child: ActivityCard(
                title: title,
                color: color,
              ),
            );
          },
        );
      },
    );
  }
}
