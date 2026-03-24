/// Mock onboarding + local profile state for register flow (in-memory).
/// Mirrors the pattern used by [FarmLocationSettingsScreen] statics.
class RegisterOnboardingState {
  RegisterOnboardingState._();

  /// Filled when user leaves [RegisterScreen] before profile photo step.
  static String? pendingUsername;
  static String? pendingEmail;

  /// Set on [OnboardingProfilePhotoScreen] when user picks an image; null if skipped.
  static String? profileImagePath;

  /// Committed when user finishes farm onboarding ("เริ่มต้นใช้งาน").
  /// Used by [SettingsScreen] and similar UI.
  static String displayUsername = 'ใบข้าว บ้านนา';
  static String? committedEmail;
  static String? avatarFilePath;

  static const String defaultDisplayUsername = 'ใบข้าว บ้านนา';

  /// Call after successful register onboarding completion.
  static void commitProfileFromPending() {
    final name = pendingUsername?.trim();
    if (name != null && name.isNotEmpty) {
      displayUsername = name;
    } else {
      displayUsername = defaultDisplayUsername;
    }
    final email = pendingEmail?.trim();
    committedEmail = (email == null || email.isEmpty) ? null : email;
    avatarFilePath = profileImagePath;
    clearPending();
  }

  static void clearPending() {
    pendingUsername = null;
    pendingEmail = null;
    profileImagePath = null;
  }
}
