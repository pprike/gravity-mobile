import "../../core/api/api_client.dart";
import "../../core/demo/demo_catalog.dart";
import "models/chat_models.dart";

class ChatRepository {
  ChatRepository(this._apiClient, {this.demoCatalog, this.demoMode = false});

  final ApiClient _apiClient;
  final DemoCatalog? demoCatalog;
  final bool demoMode;

  bool get _demo => demoMode && demoCatalog != null;

  Future<List<ChatGroup>> listGroups() async {
    if (_demo) return demoCatalog!.chatGroups;
    try {
      return await _apiClient.getList(
        "/api/v1/chat/groups",
        fromJson: (json) => ChatGroup.fromJson(json as Map<String, dynamic>),
      );
    } catch (_) {
      return const [];
    }
  }

  Future<List<ChatMessage>> listMessages(String groupId) async {
    if (_demo) {
      return List<ChatMessage>.from(
        demoCatalog!.messagesByGroup[groupId] ?? const [],
      );
    }
    try {
      return await _apiClient.getList(
        "/api/v1/chat/groups/$groupId/messages",
        fromJson: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
      );
    } catch (_) {
      return const [];
    }
  }

  Future<ChatMessage> sendMessage({
    required String groupId,
    required String body,
  }) async {
    if (_demo) {
      return demoCatalog!.sendMessage(groupId: groupId, body: body);
    }
    return _apiClient.post(
      "/api/v1/chat/groups/$groupId/messages",
      data: {"content": body},
      fromJson: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }
}
