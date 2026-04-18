import '../../../core/auth/session_invalidation_policy.dart';
import '../repository/profile_repository.dart';

/// Clears profile-related storage when the API returns 401/403 for a bearer request.
final class ProfileSessionInvalidationPolicy implements SessionInvalidationPolicy {
  const ProfileSessionInvalidationPolicy();

  @override
  Future<void> clearAuthAndUserData() =>
      ProfileRepository.clearSessionDataLocally();
}
