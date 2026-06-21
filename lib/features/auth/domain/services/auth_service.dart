import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/error/result.dart';
import '../../../../core/logging/app_logger.dart';
import '../entities/app_user.dart';

// ── Interface ────────────────────────────────────────────────────────────────

abstract interface class AuthService {
  Stream<AppUser?> get authStateChanges;
  Future<Result<AppUser, AppError>> signInWithGoogle();
  Future<Result<AppUser, AppError>> signInWithApple();
  Future<Result<void, AppError>> signOut();

  /// Permanently deletes the signed-in account and clears the local session.
  Future<Result<void, AppError>> deleteAccount();

  AppUser? get currentUser;
}

// ── Firebase implementation ──────────────────────────────────────────────────

class FirebaseAuthService implements AuthService {
  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<AppUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_mapUser);

  @override
  AppUser? get currentUser => _mapUser(_firebaseAuth.currentUser);

  // ── Google ─────────────────────────────────────────────────────────────────

  @override
  Future<Result<AppUser, AppError>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the picker.
        return const Failure(AuthError(message: 'تم إلغاء تسجيل الدخول'));
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final appUser = _mapUser(userCredential.user);
      if (appUser == null) {
        return const Failure(AuthError(message: 'تعذّر الحصول على بيانات المستخدم'));
      }
      return Success(appUser);
    } catch (e, st) {
      AppLogger.warning('Google sign-in failed', e, st);
      return Failure(AuthError(message: 'فشل تسجيل الدخول عبر Google', originalException: e));
    }
  }

  // ── Apple ──────────────────────────────────────────────────────────────────

  @override
  Future<Result<AppUser, AppError>> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = fb.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);

      // Apple only returns the name on first sign-in — patch it onto the
      // Firebase profile so it persists.
      final givenName = appleCredential.givenName;
      final familyName = appleCredential.familyName;
      if (userCredential.user?.displayName == null &&
          (givenName != null || familyName != null)) {
        final fullName = [givenName, familyName]
            .where((p) => p != null && p.isNotEmpty)
            .join(' ');
        if (fullName.isNotEmpty) {
          await userCredential.user?.updateDisplayName(fullName);
        }
      }

      final appUser = _mapUser(userCredential.user);
      if (appUser == null) {
        return const Failure(AuthError(message: 'تعذّر الحصول على بيانات المستخدم'));
      }
      return Success(appUser);
    } catch (e, st) {
      AppLogger.warning('Apple sign-in failed', e, st);
      return Failure(AuthError(message: 'فشل تسجيل الدخول عبر Apple', originalException: e));
    }
  }

  // ── Sign out ───────────────────────────────────────────────────────────────

  @override
  Future<Result<void, AppError>> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return const Success(null);
    } catch (e, st) {
      AppLogger.warning('Sign-out failed', e, st);
      return Failure(AuthError(message: 'فشل تسجيل الخروج', originalException: e));
    }
  }

  // ── Delete account ───────────────────────────────────────────────────────────

  @override
  Future<Result<void, AppError>> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Failure(AuthError(message: 'لا يوجد حساب لحذفه'));
      }

      // TODO: When we add Firestore (or other backend) user data, delete it
      // here BEFORE removing the auth account — once the account is gone we lose
      // the uid needed to locate and clean up that data.

      await user.delete();

      // Deleting the Firebase user already signs out of Firebase; also clear the
      // cached Google session so a fresh sign-in is required next time.
      await _googleSignIn.signOut();
      return const Success(null);
    } on fb.FirebaseAuthException catch (e, st) {
      if (e.code == 'requires-recent-login') {
        AppLogger.warning('Delete account requires recent login', e, st);
        return const Failure(AuthError(
          message: 'يرجى تسجيل الدخول مرة أخرى ثم إعادة المحاولة لحذف الحساب',
        ));
      }
      AppLogger.warning('Delete account failed', e, st);
      return Failure(AuthError(message: 'تعذّر حذف الحساب', originalException: e));
    } catch (e, st) {
      AppLogger.warning('Delete account failed', e, st);
      return Failure(AuthError(message: 'تعذّر حذف الحساب', originalException: e));
    }
  }

  // ── Mapping ────────────────────────────────────────────────────────────────

  AppUser? _mapUser(fb.User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }
}
