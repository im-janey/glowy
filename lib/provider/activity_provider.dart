import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ActivityProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _activities = [];
  Map<String, dynamic>? _selectedActivity;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _activityStream;

  List<Map<String, dynamic>> get activities => _activities;
  Map<String, dynamic>? get selectedActivity => _selectedActivity;

  Future<void> fetchActivities() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await _firestore
          .collection('activities')
          .where('uid', isEqualTo: uid)
          .get();

      List<Map<String, dynamic>> updatedActivities = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        Map<String, dynamic> activity = {
          'id': doc.id,
          ...data,
        };

        // Timestamp → DateTime 변환 시 null 체크
        final Timestamp? startedAtTimestamp = data['startedAt'];
        final Timestamp? finishedAtTimestamp = data['finishedAt'];

        activity['startedAt'] = startedAtTimestamp?.toDate();
        activity['finishedAt'] = finishedAtTimestamp?.toDate();

        String? categoryId = data['categoryId'];
        activity['color'] = 'grey'; // 기본값
        activity['categoryTitle'] = ''; // 기본값

        if (categoryId != null) {
          final categoryDoc =
              await _firestore.collection('categories').doc(uid).get();
          if (categoryDoc.exists) {
            Map<String, dynamic>? categoriesData = categoryDoc.data();
            if (categoriesData != null &&
                categoriesData.containsKey(categoryId) &&
                categoriesData[categoryId] is Map<String, dynamic>) {
              final catData = categoriesData[categoryId];
              activity['color'] = catData['color'] ?? 'grey';
              activity['categoryTitle'] = catData['title'] ?? '';
            }
          }
        }

        updatedActivities.add(activity);
      }

      _activities = updatedActivities;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error fetching activities: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void listenToActivities() {
    _activityStream?.cancel();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _activityStream = _firestore
        .collection('activities')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) async {
      List<Map<String, dynamic>> updatedActivities = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        Map<String, dynamic> activity = {
          'id': doc.id,
          ...data,
        };

        // Timestamp → DateTime 변환 시 null 체크
        final Timestamp? startedAtTimestamp = data['startedAt'];
        final Timestamp? finishedAtTimestamp = data['finishedAt'];

        activity['startedAt'] = startedAtTimestamp?.toDate();
        activity['finishedAt'] = finishedAtTimestamp?.toDate();

        String? categoryId = data['categoryId'];
        activity['color'] = 'grey'; // 기본값
        activity['categoryTitle'] = ''; // 기본값

        if (categoryId != null) {
          final categoryDoc =
              await _firestore.collection('categories').doc(uid).get();

          if (categoryDoc.exists) {
            Map<String, dynamic>? categoriesData = categoryDoc.data();
            if (categoriesData != null &&
                categoriesData.containsKey(categoryId) &&
                categoriesData[categoryId] is Map<String, dynamic>) {
              final catData = categoriesData[categoryId];
              activity['color'] = catData['color'] ?? 'grey';
              activity['categoryTitle'] = catData['title'] ?? '';
            }
          }
        }

        updatedActivities.add(activity);
      }

      _activities = updatedActivities;
      notifyListeners();
    });
  }

  Future<Map<String, dynamic>?> getActivityById(String docId) async {
    try {
      final doc = await _firestore.collection('activities').doc(docId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      Map<String, dynamic> activity = {
        'id': doc.id,
        ...data,
      };

      // Timestamp → DateTime 변환 시 null 체크
      final Timestamp? startedAtTimestamp = data['startedAt'];
      final Timestamp? finishedAtTimestamp = data['finishedAt'];

      activity['startedAt'] = startedAtTimestamp?.toDate();
      activity['finishedAt'] = finishedAtTimestamp?.toDate();

      return activity;
    } catch (e, stackTrace) {
      debugPrint('Error fetching activity: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  void setSelectedActivity(Map<String, dynamic>? activity) {
    _selectedActivity = activity;
    notifyListeners();
  }

  @override
  void dispose() {
    _activityStream?.cancel();
    super.dispose();
  }
}
