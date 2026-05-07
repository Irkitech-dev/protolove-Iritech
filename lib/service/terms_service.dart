import 'package:supabase_flutter/supabase_flutter.dart';

class TermsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> hasAcceptedTerms() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return false;
    }

    final response =
        await _supabase
            .from('user_terms_acceptance')
            .select()
            .eq('user_id', user.id)
            .eq('accepted', true)
            .maybeSingle();

    return response != null;
  }

  Future<void> acceptTerms() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    await _supabase.from('user_terms_acceptance').upsert({
      'user_id': user.id,
      'accepted': true,
      'accepted_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }
}
