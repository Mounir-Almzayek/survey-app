/// Contract for clearing local session when the server rejects credentials
/// (401 / 403 on authenticated calls). Keeps network layer independent of
/// feature repositories.
abstract interface class SessionInvalidationPolicy {
  Future<void> clearAuthAndUserData();
}
