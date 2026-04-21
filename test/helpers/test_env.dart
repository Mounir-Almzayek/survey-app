import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Load a minimal in-memory `.env` into `dotenv` for unit tests that depend on
/// APIConfig / AppEnvironment without requiring the real `.env` on disk.
///
/// Call once from `main()` (before accessing APIConfig-derived values) or from
/// `setUpAll` in individual test groups.
void loadTestEnv({
  String appEnv = 'prod',
  String apiBaseUrlProd = 'https://survey-api.system2030.com',
  String apiBaseUrlDev = 'https://survey-api-test.system2030.com',
  String apiBaseUrlStaging = 'https://survey-api-test.system2030.com',
  String surveyFrontendProd = 'https://survey-frontend.system2030.com',
  String surveyFrontendDev = 'https://survey-front-internal.system2030.com',
  String surveyFrontendStaging = 'https://survey-front-internal.system2030.com',
  String defaultLocale = 'ar',
}) {
  dotenv.testLoad(fileInput: '''
APP_ENV=$appEnv
API_BASE_URL_PROD=$apiBaseUrlProd
API_BASE_URL_DEV=$apiBaseUrlDev
API_BASE_URL_STAGING=$apiBaseUrlStaging
SURVEY_FRONTEND_BASE_URL_PROD=$surveyFrontendProd
SURVEY_FRONTEND_BASE_URL_DEV=$surveyFrontendDev
SURVEY_FRONTEND_BASE_URL_STAGING=$surveyFrontendStaging
SURVEY_DEFAULT_LOCALE=$defaultLocale
''');
}
