/// AI integration boundary. This MVP stays fully usable offline.
/// A future cloud provider must require explicit consent before sending data.
class AiAssistantService {
  Future<String> reply(String prompt) async {
    if (prompt.trim().isEmpty) return 'اكتب طلبك أولاً.';
    return 'مساعد الذكاء الاصطناعي قيد التطوير. '
        'سيبقى المونتاج المحلي متاحاً دون إنترنت.';
  }
}
