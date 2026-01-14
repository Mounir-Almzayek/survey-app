import 'public_links_local_repository.dart';
import 'public_links_online_repository.dart';
import '../models/public_link.dart';
import '../models/validated_public_link.dart';

class PublicLinksRepository {
  /// Get all public links (online first with local fallback)
  static Future<List<PublicLink>> getMyPublicLinks() async {
    try {
      final onlineLinks = await PublicLinksOnlineRepository.getMyPublicLinks();

      // Save all online links to local storage for offline use
      await PublicLinksLocalRepository.savePublicLinks(onlineLinks);

      return onlineLinks;
    } catch (e) {
      // Fallback to local storage if online fails
      return await PublicLinksLocalRepository.getPublicLinks();
    }
  }

  /// Validate a public link by short code
  static Future<ValidatedPublicLink> validatePublicLink(
    String shortCode,
  ) async {
    return await PublicLinksOnlineRepository.validatePublicLink(shortCode);
  }
}
