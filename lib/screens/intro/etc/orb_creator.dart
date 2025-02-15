import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class OrbCreator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Future<void> createUserProfile(String uid, String email) async {
    bool exists = await _checkUserExists(uid);
    if (!exists) {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'nickname': '',
        'createdAt': DateTime.now().toIso8601String(),
        'uid': uid,
      });

      await _initializeUserCategories(uid);
    }
  }

  Future<bool> _checkUserExists(String uid) async {
    final docSnapshot = await _firestore.collection('users').doc(uid).get();
    return docSnapshot.exists;
  }

  Future<void> _initializeUserCategories(String uid) async {
    String uuid0 = _uuid.v4().substring(0, 8);
    String uuid1 = _uuid.v4().substring(0, 8);
    String uuid2 = _uuid.v4().substring(0, 8);
    String uuid3 = _uuid.v4().substring(0, 8);
    String uuid4 = _uuid.v4().substring(0, 8);

    await _firestore.collection('categories').doc(uid).set({
      uuid0: {
        'color': 'default',
        'index': 0,
        'title': '전체',
      },
      uuid1: {
        'color': 'blue2',
        'index': 1,
        'title': '봉사활동',
      },
      uuid2: {
        'color': 'purple3',
        'index': 2,
        'title': '동아리',
      },
      uuid3: {
        'color': 'green4',
        'index': 3,
        'title': '여행',
      },
      uuid4: {
        'color': 'red1',
        'index': 4,
        'title': '독서',
      },
    });
  }
}
