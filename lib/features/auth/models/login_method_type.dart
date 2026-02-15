/// Type of login method used by the researcher
enum LoginMethodType {
  /// Login via device-bound-key or cookie verify (challenge flow)
  challenge,

  /// Unbounded auth - token returned directly from initiate (email only, no device)
  emailOnly,
}
