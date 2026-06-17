class ApiConstants {
  // Android emulator: 10.0.2.2, iOS simulator: localhost
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
  );

  // Endpoints
  static const String authGoogle = '/auth/google';
  static const String authMe = '/auth/me';
  static const String authLogout = '/auth/logout';
  static const String authFcmToken = '/auth/fcm-token';

  static const String transactions = '/transactions';
  static const String transactionsSummary = '/transactions/summary';

  static const String gmailSync = '/gmail/sync';
  static const String gmailSyncStatus = '/gmail/sync/status';
  static const String gmailSyncLogs = '/gmail/sync/logs';

  static const String categories = '/categories';
  static const String budgets = '/budgets';
  static const String budgetsProgress = '/budgets/progress';

  static const String reportsMonthly = '/reports/monthly';
  static const String reportsCategory = '/reports/category';
  static const String reportsTrend = '/reports/trend';
}
