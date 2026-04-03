import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/mock_data.dart';
import '../models/fishly_models.dart';

class FishlyFirestoreRepository {
  FishlyFirestoreRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> createAccount({
    required String displayName,
    required String email,
    required String password,
    required int coins,
    required Set<String> ownedRewardTitles,
    required String equippedAvatarAsset,
    required String equippedTankAsset,
    required List<PlannerTask> tasks,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);
    await credential.user?.reload();

    final profile = FishlyUserProfile(
      uid: _auth.currentUser!.uid,
      displayName: displayName,
      email: email,
      coins: coins,
      ownedRewardTitles: ownedRewardTitles.toList(),
      completionHistory: const <String, int>{},
      equippedAvatarAsset: equippedAvatarAsset,
      equippedTankAsset: equippedTankAsset,
    );

    await saveAccountBundle(
      uid: _auth.currentUser!.uid,
      profile: profile,
      tasks: tasks,
    );

    return credential;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<FishlyAccountBundle?> loadAccountBundle(String uid) async {
    final userDoc = await _users.doc(uid).get();
    if (!userDoc.exists) {
      return null;
    }

    final profile = _profileFromSnapshot(userDoc);
    final tasksSnapshot = await _users
        .doc(uid)
        .collection(_tasksCollection)
        .orderBy('order')
        .get();

    final tasks = tasksSnapshot.docs.map(_taskFromSnapshot).toList();
    return FishlyAccountBundle(profile: profile, tasks: tasks);
  }

  Future<void> saveAccountBundle({
    required String uid,
    required FishlyUserProfile profile,
    required List<PlannerTask> tasks,
  }) async {
    final batch = _firestore.batch();
    final userRef = _users.doc(uid);

    batch.set(userRef, {
      'displayName': profile.displayName,
      'email': profile.email,
      'coins': profile.coins,
      'ownedRewardTitles': profile.ownedRewardTitles,
      'completionHistory': profile.completionHistory,
      'equippedAvatarAsset': profile.equippedAvatarAsset ?? defaultGubbyAsset,
      'equippedTankAsset': profile.equippedTankAsset ?? defaultTankPanelAsset,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final tasksRef = userRef.collection(_tasksCollection);
    final existingTasks = await tasksRef.get();
    for (final doc in existingTasks.docs) {
      batch.delete(doc.reference);
    }

    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      batch.set(tasksRef.doc(task.id), {
        'title': task.title,
        'details': task.details,
        'completed': task.completed,
        'isBigGoal': task.isBigGoal,
        'isSubgoal': task.isSubgoal,
        'isLeftover': task.isLeftover,
        'rewardClaimed': task.rewardClaimed,
        'parentGoalId': task.parentGoalId,
        'durationLabel': task.durationLabel,
        'coins': task.coins,
        'createdDateKey': task.createdDateKey,
        'order': i,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(_usersCollection);

  static const _usersCollection = 'users';
  static const _tasksCollection = 'tasks';

  FishlyUserProfile _profileFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return FishlyUserProfile(
      uid: snapshot.id,
      displayName: data['displayName'] as String? ?? 'Fishly User',
      email: data['email'] as String? ?? '',
      coins: data['coins'] as int? ?? 0,
      ownedRewardTitles: List<String>.from(
        data['ownedRewardTitles'] as List<dynamic>? ?? const <dynamic>[],
      ),
      completionHistory: Map<String, int>.from(
        data['completionHistory'] as Map<String, dynamic>? ?? const {},
      ),
      equippedAvatarAsset: data['equippedAvatarAsset'] as String?,
      equippedTankAsset: data['equippedTankAsset'] as String?,
    );
  }

  PlannerTask _taskFromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return PlannerTask(
      id: snapshot.id,
      title: data['title'] as String? ?? '',
      details: data['details'] as String? ?? '',
      completed: data['completed'] as bool? ?? false,
      isBigGoal: data['isBigGoal'] as bool? ?? false,
      isSubgoal: data['isSubgoal'] as bool? ?? false,
      isLeftover: data['isLeftover'] as bool? ?? false,
      rewardClaimed:
          data['rewardClaimed'] as bool? ??
          (data['completed'] as bool? ?? false),
      parentGoalId: data['parentGoalId'] as String?,
      durationLabel: data['durationLabel'] as String?,
      coins: data['coins'] as int?,
      createdDateKey: data['createdDateKey'] as String?,
    );
  }
}
