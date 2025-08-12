import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class StorageService {
  static const String _appUsageKey = 'app_usage_data';
  static const String _challengesKey = 'challenges_data';
  static const String _journalEntriesKey = 'journal_entries_data';
  static const String _goalsKey = 'goals_data';
  static const String _focusSessionsKey = 'focus_sessions_data';
  static const String _userPreferencesKey = 'user_preferences';

  late SharedPreferences _prefs;

  Future<void> init() async {
    Logger.info('Initializing StorageService');
    _prefs = await SharedPreferences.getInstance();
    Logger.info('StorageService initialized successfully');
  }

  // App Usage methods
  Future<void> saveAppUsageData(List<Map<String, dynamic>> data) async {
    Logger.debug('Saving app usage data');
    final jsonString = jsonEncode(data);
    await _prefs.setString(_appUsageKey, jsonString);
    Logger.debug('App usage data saved successfully');
  }

  Future<List<Map<String, dynamic>>> getAppUsageData() async {
    Logger.debug('Loading app usage data');
    final jsonString = _prefs.getString(_appUsageKey);
    if (jsonString == null) {
      Logger.debug('No app usage data found');
      return [];
    }
    
    final data = jsonDecode(jsonString) as List;
    return data.cast<Map<String, dynamic>>();
  }

  // Challenges methods
  Future<void> saveChallengesData(List<Map<String, dynamic>> data) async {
    Logger.debug('Saving challenges data');
    final jsonString = jsonEncode(data);
    await _prefs.setString(_challengesKey, jsonString);
    Logger.debug('Challenges data saved successfully');
  }

  Future<List<Map<String, dynamic>>> getChallengesData() async {
    Logger.debug('Loading challenges data');
    final jsonString = _prefs.getString(_challengesKey);
    if (jsonString == null) {
      Logger.debug('No challenges data found');
      return [];
    }
    
    final data = jsonDecode(jsonString) as List;
    return data.cast<Map<String, dynamic>>();
  }

  // Journal entries methods
  Future<void> saveJournalEntriesData(List<Map<String, dynamic>> data) async {
    Logger.debug('Saving journal entries data');
    final jsonString = jsonEncode(data);
    await _prefs.setString(_journalEntriesKey, jsonString);
    Logger.debug('Journal entries data saved successfully');
  }

  Future<List<Map<String, dynamic>>> getJournalEntriesData() async {
    Logger.debug('Loading journal entries data');
    final jsonString = _prefs.getString(_journalEntriesKey);
    if (jsonString == null) {
      Logger.debug('No journal entries data found');
      return [];
    }
    
    final data = jsonDecode(jsonString) as List;
    return data.cast<Map<String, dynamic>>();
  }

  // Goals methods
  Future<void> saveGoalsData(List<Map<String, dynamic>> data) async {
    Logger.debug('Saving goals data');
    final jsonString = jsonEncode(data);
    await _prefs.setString(_goalsKey, jsonString);
    Logger.debug('Goals data saved successfully');
  }

  Future<List<Map<String, dynamic>>> getGoalsData() async {
    Logger.debug('Loading goals data');
    final jsonString = _prefs.getString(_goalsKey);
    if (jsonString == null) {
      Logger.debug('No goals data found');
      return [];
    }
    
    final data = jsonDecode(jsonString) as List;
    return data.cast<Map<String, dynamic>>();
  }

  // Focus sessions methods
  Future<void> saveFocusSessionsData(List<Map<String, dynamic>> data) async {
    Logger.debug('Saving focus sessions data');
    final jsonString = jsonEncode(data);
    await _prefs.setString(_focusSessionsKey, jsonString);
    Logger.debug('Focus sessions data saved successfully');
  }

  Future<List<Map<String, dynamic>>> getFocusSessionsData() async {
    Logger.debug('Loading focus sessions data');
    final jsonString = _prefs.getString(_focusSessionsKey);
    if (jsonString == null) {
      Logger.debug('No focus sessions data found');
      return [];
    }
    
    final data = jsonDecode(jsonString) as List;
    return data.cast<Map<String, dynamic>>();
  }

  // User preferences methods
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    Logger.debug('Saving user preferences');
    final jsonString = jsonEncode(preferences);
    await _prefs.setString(_userPreferencesKey, jsonString);
    Logger.debug('User preferences saved successfully');
  }

  Future<Map<String, dynamic>> getUserPreferences() async {
    Logger.debug('Loading user preferences');
    final jsonString = _prefs.getString(_userPreferencesKey);
    if (jsonString == null) {
      Logger.debug('No user preferences found');
      return {};
    }
    
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // Clear all data
  Future<void> clearAllData() async {
    Logger.warning('Clearing all stored data');
    await _prefs.remove(_appUsageKey);
    await _prefs.remove(_challengesKey);
    await _prefs.remove(_journalEntriesKey);
    await _prefs.remove(_goalsKey);
    await _prefs.remove(_focusSessionsKey);
    await _prefs.remove(_userPreferencesKey);
    Logger.info('All stored data cleared successfully');
  }
}