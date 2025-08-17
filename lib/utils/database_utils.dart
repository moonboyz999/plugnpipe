import '../services/local_supabase_helper.dart';

class DatabaseUtils {
  static Future<void> clearSampleData() async {
    final helper = LocalSupabaseHelper();
    await helper.clearSampleData();
    print('Sample data cleared. Only real requests will show now.');
  }
}
