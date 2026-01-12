import '../../../core/queue/services/request_queue_manager.dart';
import 'public_links_local_repository.dart';
import 'public_links_online_repository.dart';
import '../models/public_link.dart';
import '../models/validated_public_link.dart';
import '../models/start_public_link_request.dart';
import '../models/start_public_link_response.dart';
import '../models/save_section_answers_request.dart';
import '../models/save_section_answers_response.dart';
import '../models/public_link_active_response.dart';

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

  // Wrapper methods for other online-only operations
  static Future<ValidatedPublicLink> visitPublicLink(String shortCode) async {
    return await PublicLinksOnlineRepository.visitPublicLink(shortCode);
  }

  static Future<StartPublicLinkResponse> startPublicLinkResponse(
    String shortCode, {
    StartPublicLinkRequest? request,
  }) async {
    final response = await PublicLinksOnlineRepository.startPublicLinkResponse(
      shortCode,
      request: request,
    );

    // 1. Initialize local answers progress
    await PublicLinksLocalRepository.saveSectionAnswersRequest(
      shortCode: shortCode,
      responseId: response.responseId,
      sectionId: response.firstSection?.id ?? 0,
      request: const SaveSectionAnswersRequest(answers: [], isSynced: true),
    );

    // 2. Mark as an active/started response
    final publicLink =
        await PublicLinksLocalRepository.getPublicLinkByShortCode(shortCode);
    await PublicLinksLocalRepository.saveActiveResponse(
      PublicLinkActiveResponse(
        shortCode: shortCode,
        responseId: response.responseId,
        surveyTitle: publicLink?.surveyTitle ?? '',
        lastSectionId: response.firstSection?.id ?? 0,
        totalSections: publicLink?.survey?.sections?.length ?? 1,
        updatedAt: DateTime.now(),
      ),
    );

    return response;
  }

  static Future<SaveSectionAnswersResponse> saveSectionAnswers({
    required String shortCode,
    required int responseId,
    required int sectionId,
    required SaveSectionAnswersRequest request,
  }) async {
    // 1. Prepare request (mark as NOT synced)
    final localRequest = request.copyWith(isSynced: false);

    // 2. Save progress locally first
    await PublicLinksLocalRepository.saveSectionAnswersRequest(
      shortCode: shortCode,
      responseId: responseId,
      sectionId: sectionId,
      request: localRequest,
    );

    try {
      // 3. Attempt to save online
      final response = await PublicLinksOnlineRepository.saveSectionAnswers(
        shortCode: shortCode,
        responseId: responseId,
        sectionId: sectionId,
        request: request,
      );

      // 4. On success, update local memory and mark as synced
      await PublicLinksLocalRepository.saveSectionAnswersRequest(
        shortCode: shortCode,
        responseId: responseId,
        sectionId: sectionId,
        request: localRequest.copyWith(isSynced: true),
      );

      // 5. Update or remove from active responses index
      if (response.isComplete) {
        await PublicLinksLocalRepository.removeActiveResponse(shortCode);
      } else if (response.nextSection != null) {
        final activeResponses =
            await PublicLinksLocalRepository.getActiveResponses();
        final currentActive = activeResponses
            .where((r) => r.shortCode == shortCode)
            .firstOrNull;
        if (currentActive != null) {
          await PublicLinksLocalRepository.saveActiveResponse(
            currentActive.copyWith(
              lastSectionId: response.nextSection!.id,
              updatedAt: DateTime.now(),
            ),
          );
        }
      }

      return response;
    } catch (e) {
      // If online fails, it remains as isSynced = false in local storage
      rethrow;
    }
  }

  /// Add save section answers request to offline queue
  static Future<void> enqueueSaveSectionAnswers({
    required String shortCode,
    required int responseId,
    required int sectionId,
    required SaveSectionAnswersRequest request,
  }) async {
    // 1. Prepare request (mark as NOT synced)
    final localRequest = request.copyWith(isSynced: false);

    // 2. Save progress locally
    await PublicLinksLocalRepository.saveSectionAnswersRequest(
      shortCode: shortCode,
      responseId: responseId,
      sectionId: sectionId,
      request: localRequest,
    );

    // 3. Add to queue with a success callback to update local memory
    final apiRequest = PublicLinksOnlineRepository.getSaveSectionAnswersRequest(
      shortCode: shortCode,
      responseId: responseId,
      sectionId: sectionId,
      request: request,
    );

    await RequestQueueManager().queueRequest(
      apiRequest,
      onSuccess: (response) async {
        // When the queue successfully sends the request, update local memory to isSynced: true
        await PublicLinksLocalRepository.saveSectionAnswersRequest(
          shortCode: shortCode,
          responseId: responseId,
          sectionId: sectionId,
          request: localRequest.copyWith(isSynced: true),
        );

        // Also check if we should update/remove from active index
        final syncData = SaveSectionAnswersResponse.fromJson(
          response.data['data'] ?? response.data,
        );
        if (syncData.isComplete) {
          await PublicLinksLocalRepository.removeActiveResponse(shortCode);
        } else if (syncData.nextSection != null) {
          final activeResponses =
              await PublicLinksLocalRepository.getActiveResponses();
          final currentActive = activeResponses
              .where((r) => r.shortCode == shortCode)
              .firstOrNull;
          if (currentActive != null) {
            await PublicLinksLocalRepository.saveActiveResponse(
              currentActive.copyWith(
                lastSectionId: syncData.nextSection!.id,
                updatedAt: DateTime.now(),
              ),
            );
          }
        }
      },
    );
  }

  /// Get local progress for a specific section
  static Future<SaveSectionAnswersRequest?> getSectionProgress({
    required String shortCode,
    required int responseId,
    required int sectionId,
  }) async {
    return await PublicLinksLocalRepository.getSectionAnswersRequest(
      shortCode: shortCode,
      responseId: responseId,
      sectionId: sectionId,
    );
  }

  /// Determine the next section or completion status offline
  static Future<SaveSectionAnswersResponse> getNextSectionOffline({
    required String shortCode,
    required int sectionId,
  }) async {
    final publicLink =
        await PublicLinksLocalRepository.getPublicLinkByShortCode(shortCode);

    if (publicLink == null || publicLink.survey == null) {
      return const SaveSectionAnswersResponse(isComplete: false);
    }

    final sections = publicLink.survey!.sections ?? [];
    if (sections.isEmpty) {
      return const SaveSectionAnswersResponse(isComplete: true);
    }

    // Find current section index
    final currentIndex = sections.indexWhere((s) => s.id == sectionId);

    if (currentIndex != -1 && currentIndex < sections.length - 1) {
      // There is a next section
      final nextSection = sections[currentIndex + 1];

      // Update active response index with the new offline section
      final activeResponses =
          await PublicLinksLocalRepository.getActiveResponses();
      final currentActive = activeResponses
          .where((r) => r.shortCode == shortCode)
          .firstOrNull;
      if (currentActive != null) {
        await PublicLinksLocalRepository.saveActiveResponse(
          currentActive.copyWith(
            lastSectionId: nextSection.id,
            updatedAt: DateTime.now(),
          ),
        );
      }

      return SaveSectionAnswersResponse(
        nextSection: nextSection,
        isComplete: false,
      );
    }

    // No more sections - mark as complete locally
    if (currentIndex == sections.length - 1) {
      await PublicLinksLocalRepository.removeActiveResponse(shortCode);
    }

    return const SaveSectionAnswersResponse(isComplete: true);
  }

  /// Get all active responses started by the user
  static Future<List<PublicLinkActiveResponse>> getActiveResponses() async {
    return await PublicLinksLocalRepository.getActiveResponses();
  }
}
