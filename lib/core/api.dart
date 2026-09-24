// PAMOJI API client — every call goes to the shared Base44 backend.
// The session token lives in flutter_secure_storage (encrypted on device).
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String kBaseUrl = 'https://lyra-d13d23f6.base44.app/functions';
const List<String> kLocations = [
  'Blantyre', 'Lilongwe', 'Mzuzu', 'Zomba', 'Kasungu', 'Mangochi', 'Karonga',
  'Salima', 'Balaka', 'Dedza', 'Nkhotakota', 'Mulanje', 'Thyolo', 'Chiradzulu',
  'Rumphi', 'Nsanje', 'Chikwawa',
];

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class PamojiApi {
  static const _storage = FlutterSecureStorage();
  static String? _token;

  static Future<void> init() async {
    _token = await _storage.read(key: 'pamoji_token');
  }

  static bool get hasToken => _token != null;

  static Future<void> _saveToken(String? t) async {
    _token = t;
    if (t == null) {
      await _storage.delete(key: 'pamoji_token');
    } else {
      await _storage.write(key: 'pamoji_token', value: t);
    }
  }

  static Future<Map<String, dynamic>> call(String fn, [Map<String, dynamic>? payload]) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/$fn'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({...?payload, if (_token != null) 'token': _token}),
      ).timeout(const Duration(seconds: 20));
      final data = json.decode(res.body);
      if (data is Map<String, dynamic>) {
        if (data['ok'] == false) {
          if (data['error'] == 'Session expired. Please sign in again.' ||
              data['error'] == 'Account suspended.') {
            await _saveToken(null);
          }
          throw ApiException((data['error'] as String?) ?? 'Request failed.');
        }
        return data;
      }
      throw ApiException('Unexpected response from server.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          'Network problem — check your connection and try again.');
    }
  }

  // ---- auth ----
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String displayName,
    required String location,
    String? phone,
  }) async {
    final res = await call('pamojiAuth', {
      'action': 'register',
      'email': email,
      'password': password,
      'fullName': fullName,
      'displayName': displayName,
      'location': location,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    await _saveToken(res['token'] as String);
    return res;
  }

  static Future<void> login(String email, String password) async {
    final res = await call('pamojiAuth',
        {'action': 'login', 'email': email, 'password': password});
    await _saveToken(res['token'] as String);
  }

  static Future<void> verifyEmail(String code) async {
    await call('pamojiAuth', {'action': 'verifyEmail', 'code': code});
  }

  static Future<void> logout() async {
    try { await call('pamojiAuth', {'action': 'logout'}); } catch (_) {}
    await _saveToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pamoji_recent');
  }

  static Future<Map<String, dynamic>> me() =>
      call('pamojiAuth', {'action': 'me'});

  // ---- catalog ----
  static Future<Map<String, dynamic>> home() =>
      call('pamojiCatalog', {'action': 'home'});

  static Future<Map<String, dynamic>> search({
    String? query,
    String? categoryId,
    String? condition,
    String? location,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'relevance',
    int limit = 20,
    int offset = 0,
  }) =>
      call('pamojiCatalog', {
        'action': 'search',
        if (query != null && query.isNotEmpty) 'query': query,
        if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
        if (condition != null && condition.isNotEmpty) 'condition': condition,
        if (location != null && location.isNotEmpty) 'location': location,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        'sortBy': sortBy,
        'limit': limit,
        'offset': offset,
      });

  static Future<Map<String, dynamic>> listing(String id) =>
      call('pamojiCatalog', {'action': 'listing', 'listingId': id});

  static Future<void> favorite(String listingId, bool add) => call(
      'pamojiCatalog',
      {'action': add ? 'favorite' : 'unfavorite', 'listingId': listingId});

  static Future<Map<String, dynamic>> myFavorites() =>
      call('pamojiCatalog', {'action': 'myFavorites'});

  static Future<Map<String, dynamic>> sellerProfile(String sellerId) =>
      call('pamojiSeller', {'action': 'sellerProfile', 'sellerId': sellerId});

  // ---- chat ----
  static Future<Map<String, dynamic>> startConversation(String listingId) =>
      call('pamojiChat', {'action': 'start', 'listingId': listingId});

  // ---- notifications ----
  static Future<Map<String, dynamic>> notifications() =>
      call('pamojiReports', {'action': 'notifications'});

  // ---- recently viewed: cached locally, no DB writes per view ----
  static Future<List<String>> recentIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('pamoji_recent') ?? [];
  }

  static Future<void> addRecent(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await recentIds();
    ids.remove(id);
    ids.insert(0, id);
    await prefs.setStringList('pamoji_recent', ids.take(20).toList());
  }
}
