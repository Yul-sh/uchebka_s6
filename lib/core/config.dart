const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080/api',
);

const inactivityTimeout = Duration(minutes: 3);
const inactivityWarning = Duration(seconds: 30);
const maxSessionDuration = Duration(hours: 8);
