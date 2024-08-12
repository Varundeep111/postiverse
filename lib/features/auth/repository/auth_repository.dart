import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:reddit_clone/core/type_def.dart';
import 'package:reddit_clone/models/user_model.dart';

final AuthRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSingInProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return left(Failure('Google sign-in failed: No user data received'));
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth == null) {
        return left(
            Failure('Google sign-in failed: No authentication data received'));
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential;
      if (isFromLogin) {
        userCredential = await _auth.signInWithCredential(credential);
      } else {
        userCredential =
            await _auth.currentUser!.linkWithCredential(credential);
      }

      UserModel userModel;
      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          name: userCredential.user!.displayName ?? 'No Name',
          profilePic: userCredential.user!.photoURL ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: true,
          Karma: 0,
          awards: [
            'awesomeAns',
            'gold',
            'platinum',
            'helpful',
            'plusone',
            'rocket',
            'thankyou',
            'til',
          ],
        );
        await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        // Handle case where user data may not be found
        DocumentSnapshot docSnapshot =
            await _users.doc(userCredential.user!.uid).get();
        if (!docSnapshot.exists || docSnapshot.data() == null) {
          return left(Failure('User data not found'));
        }
        userModel =
            UserModel.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }
      return right(userModel);
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Firebase error'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> signInAsGuest() async {
    try {
      var userCredential = await _auth.signInAnonymously();
      UserModel userModel = UserModel(
        name: 'Guest',
        profilePic: Constants.avatarDefault,
        banner: Constants.bannerDefault,
        uid: userCredential.user!.uid,
        isAuthenticated: false,
        Karma: 0,
        awards: [],
      );
      await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      return right(userModel);
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Firebase error'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) {
        throw Exception('User data is null');
      }

      // Ensure data is of the expected type
      if (data is! Map<String, dynamic>) {
        throw Exception('User data format is incorrect');
      }

      // Convert awards list to List<String>
      final awardsList = (data['awards'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ?? [];

      final userModelData = {
        ...data,
        'awards': awardsList,
      };

      // Convert data to UserModel
      try {
        return UserModel.fromMap(userModelData as Map<String, dynamic>);
      } catch (e) {
        throw Exception('Error converting user data: $e');
      }
    });
  }

  Future<void> logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
