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
        Map<String, dynamic> activity = {'id': doc.id, ...doc.data()};

        String? categoryId = activity['categoryId'];

        if (categoryId != null) {
          final categoryDoc =
              await _firestore.collection('categories').doc(uid).get();

          if (categoryDoc.exists) {
            Map<String, dynamic>? categoriesData = categoryDoc.data();
            if (categoriesData != null &&
                categoriesData.containsKey(categoryId) &&
                categoriesData[categoryId] is Map<String, dynamic>) {
              activity['color'] = categoriesData[categoryId]['color'] ?? 'grey';
            }
          }
        } else {
          activity['color'] = 'grey';
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
        Map<String, dynamic> activity = {'id': doc.id, ...doc.data()};

        String? categoryId = activity['categoryId'];

        if (categoryId != null) {
          final categoryDoc =
              await _firestore.collection('categories').doc(uid).get();

          if (categoryDoc.exists) {
            Map<String, dynamic>? categoriesData = categoryDoc.data();
            if (categoriesData != null &&
                categoriesData.containsKey(categoryId) &&
                categoriesData[categoryId] is Map<String, dynamic>) {
              activity['color'] = categoriesData[categoryId]['color'] ?? 'grey';
            }
          }
        } else {
          activity['color'] = 'grey';
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
      return doc.exists ? {'id': doc.id, ...doc.data()!} : null;
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
